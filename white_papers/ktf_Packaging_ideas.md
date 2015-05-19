Packaging in the Github Era
===========================

The goal of this document is to revise CMS packaging procedures at the light of new services like Github which allow to simply store and maintain a large amount sourcecode, providing among other things a nice and integrated web GUI to browse the code, including its history and an integrated bug tracker.

In particular what we want to achieve is the following:

- Provide a "mirroring protocol" to be used for keeping track of pristine sources for external packages, the additions and customization provided by some party (e.g. an experiment) and the build instructions.
- Provide a "build protocol" for the build instructions so that build instructions can be used by a variety of tools, including, but not limited to, cmsBuild.

----
The mirroring protocol
======================

The "mirroring protocol"" is just a nice word to describe how external software sourcecode is mirrored and customizations are kept track of.

We divide the problem in two cases:

1. Projects for which it's easy to maintain a full mirror on github. This is the case in particular for:
   
    - projects already maintained on github.
    - projects which have an official mirror on github.
    - projects which are in git or any VCS which has automatic, incremental mirroring to git support (SVN, HG).
  
2. Projects for which a full mirror on github is not possible or too complicated to setup:
    - CVS maintained projects.
    - Projects for which we only have tarballs.

In order to reduce clutter in the official cms organization and to generalize the concept, we have created a new origanization called "cms-externals".

## 1. Projects which are maintained in Github

For these kind of projects (like zlib) the protocol includes a setup phase, where a fork of the official repository is done and tracking scripts have to be set in place and a customization phase, where experiment customizations to the repository are put in place.

For the zlib case this translate into the following:

- Go to the github official zlib mirror <https://github.com/madler/zlib> and fork it to the `cms-externals` organization. This will not only guarantee that we can customize sources, but it will homogenize the namespace and secure source availability even in the case the official sourcecode is removed for whatever reason.

- One or more given tags are used by CMS in CMSDIST, for this particular example we will use [v1.2.7](https://github.com/cms-externals/zlib/tree/v1.2.7). For each of the used tags, we create a new branch, `cms/v1.2.7`.

```bash
git clone https://github.com/cms-externals/zlib.git
cd zlib
git checkout -b cms/v1.2.7 v1.2.7
```

The purpose of the new branch is to keep track of CMS specific changes and build instructions. In this particular case we will simply add a `build.sh` script:

```bash
if [ $HEP_COMPILER = "icc" ]; then                                                                                                                                                                             
  CC="icc -fPIC"
fi

case $HEP_ARCH in
   *_amd64_gcc4[56789]* )
     CFLAGS="-fPIC -O3 -DUSE_MMAP -DUNALIGNED_OK -D_LARGEFILE64_SOURCE=1 -msse3" \
     ./configure --prefix=$HEP_BUILDROOT
     ;;
   *_armv7hl_gcc4[56789]* )
     CFLAGS="-fPIC -O3 -DUSE_MMAP -DUNALIGNED_OK -D_LARGEFILE64_SOURCE=1" \
     ./configure --prefix=$HEP_BUILDROOT
     ;;
   * )
     CC=$CC ./configure --prefix=$HEP_BUILDROOT
     ;;
esac

make $HEP_MAKEPROCESSES
```

For the moment ignore the contents of the script. It's enough to consider it a CMS specific customization. The customization is then added to the branch and published to the repository via:

```bash
git add build.sh
git commit -a -m'Add build script' build.sh
git push origin HEAD:cms/v1.2.7
```

### Keeping track of changes

Just like any other bit of software externals are moving targets and we will need to have a way for updating our `cms-eternals` mirror on Github. This is simply done by routinely pushing to our mirror a copy of the commits, branches and tags we are interested in. The process can either be done by hand, or automated via a cronjob / jenkins. For example lets assume a new version of zlib appears, `v1.2.8`:

```bash
git remote add upstream https://github.com/madler/zlib
git fetch --tags upstream
git push --tags origin 
```

is enough to update the mi

Once this is done, our changes on top of an additional release can easily be ported via git rebase. Let's say for example we want to backport our changes to `v1.2.8`, we will simply have to do the following:

```bash
git checkout -b cms/v1.2.8 v1.2.8
git rebase -i --onto cms/v1.2.8 v1.2.7 cms/1.2.7
git push origin HEAD:cms/v1.2.8
```

### Backing up Github repositories.

Given we do not want to rely on Github for backups, we will have to maintain our own mirror on afs, just in case. This is easily done via:

```bash
git clone --mirror https://github.com/cms-externals/zlib.git
```

and subsequent:

```bash
cd zlib
git fetch --mirror
```

on some CERN provided server. Notice that for a number of project there are already multiple non-authoritative mirrors, so this might actually be an overkill.

### Projects which are easy to maintain in Github

Having a project maintained officially in Github is not strictly a requirement. Any project which can easily have a mirror on Github, for example because it's already maintained in git, can easily follow the instructions so far. The only reccomandation is to setup a repository naming convetion for those which are hosted in alien VCS, like svn or mercurial, so that in case an official git mirror happens, we can use it directly. The proposal is to simply add `-svn`, `-hg` to the name of our mirror.

### Projects maintained in CVS or completely outside VCS

In case automated mirroring of these projects not possible, the best strategy is to simply import the tarballs with the tags we are interested in. For example for a package like coral, assuming we have a tarball coral.tgz from CVS, we could simply create an empty repository:

```bash
git init
tar xzvf coral.tgz
git add -A .
git commit -m'Import of CORAL_X_Y_Z'
git tag CORAL_X_Y_Z
```

when a new version arrives it can either be put in a separate branch (which git will happily compress together with the rest) or put on top of a previous tag, following some logic (`CORAL_1_0_1` for example could sit as a commit on top of `CORAL_1_0_0`, for example). Once the mirror repository is set up this way, we can then easily follow all the prescriptions described so far for the trivial mirroring case.

----
The build protocol
==================

Different experiment use different tools to build their externals. In some cases the same experiment is using more then one tool or in other cases it's desiderable to have move forward and use a new packaging / deployment scheme. Thinking that agreement can be reached on a single tool extremely naive at HEP level for one single architecture, leave alone the fact that outside HEP the balkanization of build tools is even more profound. The only hope IMHO is to converge on a build protocol, a series of rules and conventions that different packaging tools within HEP adopt, in order to interact with each other.

I therefore propose that CMS adopts the following convention, hoping that others will follow:

- Source unpacking happens by fetching a branch / tag / hash from a git based repository.
- The tag contains a `./build.sh` file which is used to drive the build. It takes expectes the following variables to be defined:

  - `HEP_COMPILER`: the compiler being used.
  - `HEP_SOURCEDIR`: where the sources checked out from github are located.
  - `HEP_BUILDROOT`: where the build is actually performed.
  - `HEP_INSTALLROOT`: where the built software is installed, during the build.
  - `HEP_ARCH`: the architecture for the build.

Moreover it expects to have the quadruplet of variables:

  - `<EXTERNAL>_ROOT`
  - `<EXTERNAL>_VERSION`
  - `<EXTERNAL>_GROUP`
  - `<EXTERNAL>_REVISION`

to be defined for each dependency it has and for the package being built itself, where `<EXTERNAL>` is an all upper case label, for example `ZLIB_ROOT=/usr/local/zlib`, `ZLIB_VERSION=1.2.8`, `ZLIB_GROUP=external`, `ZLIB_REVISION=cms2`. If not present, `build.sh` script would default to:

```bash
cd $HEP_SOURCEDIR
./configure --prefix=$HEP_INSTALLROOT
make ${HEP_MAKEPROCESSES+-j $MAKEPROCESSES} 
make install
```

How things are relocated, packaged, and the scheduling of different build steps (fetchin sources and so on), is left to the implementor.

Advantages of this approach
===========================

There are several advantages for this approach to building externals:

- Sources and customizations are easily available, via the Github GUI. 
- We reduce the amount of patches flying around when building externals like root and so on, everything is kept in a git branch.
- Different experiment could use the same repository and keep their own customization in separate branches, yet the fact we agree on a formal protocol to drive the build would allow more code reusage between different experiments.
- Tools can migrate adiabatically to the new setup, one external at the time.
- Maintainance of the mirrors is a triavial operation which could be done for all experiments.
- Maintainance of the backup is a trivial operation which could be done for all experiments.
- Diffferent packaging system could be used for packaging externals. For example CMS could use PKGTOOLS as usual, but there could be a root distribution which uses `homebrew` on mac which gets built using the same `build.sh` script, invoked in a different manner.
