# Portage Package Manager

Portage [1] is the official package manager and distribution system for Gentoo
Linux [2]. It is also used by ChromeOS [3], CoreOS (now called Container Linux)
[4], Sabayon [5], Funtoo Linux [6], among others [7].

Portage is based on the concept of ports collections from FreeBSD. Gentoo is
sometimes referred to as a meta-distribution due to the extreme flexibility of
Portage, which makes it operating-system-independent. The Gentoo Prefix project
[8] is concerned with using Portage to manage packages in other operating
systems, such as other Linux distributions, as well as BSDs, macOS, Solaris,
and Windows.

The Package Manager Specification project (PMS) [9] standardises and documents
the behaviour of Portage, allowing Gentoo ebuild packages to be used with
alternative package managers such as Paludis and pkgcore. Its goal is to specify
the exact set of features and behaviour of package managers and ebuilds, serving
as an authoritative reference for Portage.

This document will walk you through preparing and using Portage to install the
HSF packaging group's test software stack. We build upon the documentation for
starting a Gentoo Linux container image available on GitHub [10]. If you intend
to install Gentoo Linux on your machine, you are encouraged to follow the Gentoo
Handbook for your platform [11]. If you do not use Linux, you can bootstrap a
Gentoo Prefix installation instead [12].

## Creating the Configuration to Build the Test Stack

In order to install the test stack, we need to tell Portage what we want to
install, which options to use when compiling, etc. This can be done by changing
the default configuration files that come with Portage.

The first and simplest file we need to modify is the `world` file, which
contains a list of packages that should be installed and maintained up to date.
It simply contains one package name per line. Our world file contains the
following:

```
dev-libs/boost
sci-physics/geant
sci-physics/root
```

These packages will already pull in CLHEP, GSL, etc as dependencies, so we don't
need to specify anything else for now. I am omitting Qt 5 from the list, because
the other packages will already take quite long to compile. To install Qt from
within the running image once you finish building it, just type `emerge
qtgui:5`. If you would like to play with nix and/or guix, you can also `emerge
nix guix` to install them.

We also need to tell Portage which options we want to enable when building
packages. We will do this in two ways, one that affects all packages, and one 
that only affects individual packages. For the first, we will change the main
configuration file for Portage, `/etc/portage/make.conf`. Here is what our
file will contain:

```
CHOST="x86_64-pc-linux-gnu"

CFLAGS="-O2 -pipe"
CXXFLAGS="${CFLAGS}"

# containers and sandbox don't work well together
FEATURES="-news -sandbox -usersandbox"

VIDEO_CARDS=""

CPU_FLAGS_X86="mmx mmxext popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"

USE="bindist gif jpeg json perl png python tiff truetype xml"
```

The file is quite self-explanatory. The important variable being the `USE`
variable, that contains a list of optional features that should be enabled.
Features could be listed as `-feature` too, in which case they would be disabled
instead.

The next thing is to choose some packages from the testing branch, since by
default only packages marked as stable will be seen by Portage. For each ebuild,
there is a variable called `KEYWORDS` that indicates on which architectures the
package is supposed to work. A keyword like `arch` (e.g. `amd64` or `arm`)
indicates a stable package, while a keyword like `~arch` (e.g. `~x64-macos`)
indicates an unstable package. Therefore, we put our desired list of unstable
packages in `/etc/portage/packages.accept_keywords`:

```
dev-util/cmake ~amd64

dev-libs/boost ~amd64
dev-util/boost-build ~amd64

sci-physics/clhep ~amd64
sci-physics/geant ~amd64
sci-physics/geant-data ~amd64

dev-libs/xxhash ~amd64
net-libs/davix ~amd64
sci-libs/gsl ~amd64
dev-libs/vc ~amd64
sci-physics/root ~amd64
```

The final bit of configuration is to list the options that we want to enable
for our packages. This is done in `/etc/portage/package.use`, which can be a
simple file or a directory where the options can be split into multiple files.
We use one per package. The format is one package name per line, with options
listed after the package name itself, as shown below for ROOT:

```
# needed by sci-physics/root
sys-libs/zlib minizip
dev-libs/libpcre2 pcre16

sci-physics/root X asimage davix gdml gsl math minuit pythia6 pythia8 python
sci-physics/root roofit root7 ssl tbb threads tiff tmva unuran vc xml xrootd
```

Now Portage is fully configured, we just need to prepare an image with the files
in the right places and build everything that is not already installed. Gentoo
is a source distribution, hence GCC 6.4 is already installed by default, as well
as Python 2 and 3. Moreover, there are no `-dev` versions of packages, because
the headers are needed to build from source, so they are installed by default.

## Installing the Test Stack with Docker

To make installation of the stack as simple as possible, a `Dockerfile` has been
provided. To build the test stack, simply go to the `docker` directory and type

```bash
$ docker build -t hsf-test-stack .
```

Since we already configured Portage to do what we want, all that's needed is to
copy files over then call `emerge -u world` to install what's missing:

```Dockerfile
FROM gentoo/portage
FROM gentoo/stage3-amd64

COPY --from=gentoo/portage /usr/portage /usr/portage

COPY portage /etc/portage
COPY world /var/lib/portage/world

RUN emerge --jobs 4 -u world \
 && rm -rf /usr/portage/distfiles/*

CMD /bin/bash -l
```

After installing everything, we clean up the download area to reduce the size
of the image. For convenience, a pre-built stack can be pulled with:

```bash
$ docker pull amadio/hsf-test-stack
```

if you don't want to wait for some ~100 packages to be built and installed.

## Using the Test Stack

Once the build process finishes, you can start the container with the whole
stack installed with

```bash
$ docker run -it hsf-test-stack
```

To get X applications to work, you will need to forward the `DISPLAY` settings,
and the magic cookie for X:

```bash
$ docker run -it -e DISPLAY=$DISPLAY -v /tmp:/tmp hsf-test-stack
```

## Adding New Packages

Adding new packages is done with the `emerge` command. You can search for
packages with `emerge --search`, and install with, e.g. `emerge -av <package>`.
For more information, please refer to the documentation in the Gentoo Wiki [13].

## References

1.  https://wiki.gentoo.org/wiki/Portage
2.  https://www.gentoo.org
3.  https://www.chromium.org/chromium-os
4.  https://coreos.com
5.  https://www.sabayon.org
6.  https://www.funtoo.org
7.  https://wiki.gentoo.org/wiki/Distributions_based_on_Gentoo
8.  https://wiki.gentoo.org/wiki/Project:Prefix
9.  https://wiki.gentoo.org/wiki/Package_Manager_Specification
10. https://github.com/gentoo/gentoo-docker-images
11. https://wiki.gentoo.org/wiki/Handbook:Main_Page
12. https://wiki.gentoo.org/wiki/Project:Prefix/Bootstrap
13. https://wiki.gentoo.org
