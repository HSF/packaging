Notes on Software Packaging Concepts and Tools
==============================================
Whilst "Packaging" may seem a simple concept, discussion in this HSF group
has highlighted several different viewpoints and understandings. This document
naturally covers those of the author, and is something of a brain dump (and a
draft at that...).
Howeevr, it's hoped that this can be compared with others within HSF to gain
a common viewpoint/vocabulary and to resolve any misunderstandings (including
those of the author!).

In this document, "Packaging" is taken to mean "the process of building,
installing, using and updating 1-N software projects on a system":

- **Project**: A software project such as ROOT or Geant4, a thing to be packaged
- **Package**: An installation of a **Project** performed through a **Package
Manager**
- **Package Manager**: The tool used to build/install/update 1-N **Packages**

This should be an easy process for anybody from a new user to sysadmin, and
to give an example, here's how the Qt project can be installed and updated
on the command line using the [Homebrew](https://github.com/Homebrew/homebrew.git) package manager

```
... install the package manager ...
$ git clone https://github.com/Homebrew/homebrew.git

... install a package ...
$ brew install qt
... Qt and all its dependencies are installed ...

... use it ...
$ qmake <args>

... a new version comes out ...
$ brew upgrade qt
```

Similar workflows hold for other package managers, and we'd like the same for
any HEP experiment software, e.g.

```
$ brew install <yourexperiment>
... everything gets installed...

... use it ...
$ runmysoftware

... version X is released ...
$ brew upgrade <yourexperiment>
```

This document attempts to cover aspects of the HEP software development
cycle that appear (to the author at least) to have limited use of simple
installations like the above example.


Package Organization
====================
The software development cycle in HEP projects is usually of a semi-rolling
nature (caveat: author's observation). That is

- "Stable/Official" releases appear on relatively short timescales (days-weeks)
- Several "Stable" releases may be installed concurrently, and users switch
between these depending on the task at hand
- A "Stable" release may have several variants using different versions of
 third party packages (e.g. ROOT)

One might term this a "rolling release with snapshots". As users of
HEP experiment software tend also to be its developers, an "Unstable" release
may be present. This might include packages for newer versions of third party
projects. HEP's grey area of user-developers doesn't create any extra
requirements on the packaging system as such, but can lead to certain
antipatterns being employed.

As a short aside, one particularly common antipattern is to couple the build/development environment (Makefiles etc) to the package manager tool. An example
would be to have a project's Makefile calling `rpm` to determine installed
package paths. Such a coupling prevents the project *even being compiled* on
a non-rpm based system, and requires significant rewriting of the Makefile
if the project itself moves to a different package manager.

Installing Multiple Concurrent Package Versions
-----------------------------------------------
When multiple versions of software projects are required, a typical
filesystem layout of packages is:

```
+-<somedir>
  +- foo/
  |  +- 1.0.0/
  |  |   +- bin/
  |  |      +- foo <-------(uses)
  |  +- 2.0.0/             |
  |     +- bin/            |
  |        +- foo <-----------(uses)
  +- bar/                  |  |
     +- 1.2.3/             |  |
     |   +- include        |  |
     |   +- lib/           |  |
     |      +- libbar.so <-|  |
     +- 3.0.0/                |
        +- include            |
        +- lib/               |
           +- libbar.so <-----|
```

Each package is installed to its own, isolated **Single Rooted** directory
following the usual UNIX/POSIX [Filesystem Hierarchy Standard](http://www.linuxfoundation.org/collaborate/workgroups/lsb/fhs) for headers, libraries and
programs. This may get further complicated if projects are packaged against
multiple versions of other packages. For example, in the above case,
another `foo-1.0.0-bar-3.0.0` might be packaged which links `foo` to
`bar-3.0.0`. Such a structure is in general *very* difficult to use without
a good **Configuration Management** tool such as:

- [Environment Modules](http://modules.sourceforge.net)

Whilst UNIX environment variables are the go-to tool for configuration management in HEP, their current use in can be extremely fragile as

- Users can (and do!) overwrite or otherwise alter the environment
- A very large number of variables are set (typically *at least* 3 per package, plus entries in various `PATH`s, making issues awkward to debug
- Environment setup is often not accompanied by a commesurate and clean
tear down operation unless care is taken by the user

This is not to say that the environment should not be used, rather that
any changes should be minimal and follow POSIX standards. An alternative and
more powerful system are *Link Based Environments* (author's term). Here,
a **Single Rooted** directory is created into the which the required set
of packages are soft/hard linked, e.g.

```
+-<somedir>
  +- linkbasedenv-1.0.0/
  |   +- bin/
  |   |   +- foo -------(softlink)
  |   +- include        |
  |      +- bar.h ------|--(softlink)
  |   +- lib/           |  |
  |      +- libbar.so --|--|--(softlink)
  +- foo/               |  |  |
  |  +- 1.0.0/          |  |  |
  |  |   +- bin/        |  |  |
  |  |      +- foo <----|  |  |
  |  +- 2.0.0/             |  |
  |     +- bin/            |  |
  |        +- foo          |  |
  +- bar/                  |  |
     +- 1.2.3/             |  |
     |   +- include/       |  |
     |      +- bar.h <-----|  |
     |   +- lib/              |
     |      +- libbar.so <----|
     +- 3.0.0/
        +- include
        +- lib/
           +- libbar.so
```

From the user perspective, the `linkbasedenv-1.0.0` directory behaves just
like `/usr` or `/usr/local` and can be considered a "Snapshot" in the rolling
release. The simplicity of configuration comes from the use of the FHS layout
and thus only single entries in the UNIX `PATH`s are needed to configure
and use everything. As the package manager tool handles the creation
of the soft/hard links, the user has a strong guarantee of API/ABI
compatibility. In addition, new environments can be created easily later on,
e.g.

```
+-<somedir>
  +- linkbasedenv-1.0.0/
  |  ... still links to foo-1.0.0, bar-1.2.3 ...
  +- linkbasedenv-2.0.0/
  |   +- bin/
  |   |   +- foo -------(softlink)
  |   +- include        |
  |      +- bar.h ------|--(softlink)
  |   +- lib/           |  |
  |      +- libbar.so --|--|--(softlink)
  +- foo/               |  |  |
  |  +- 1.0.0/          |  |  |
  |  |   +- bin/        |  |  |
  |  |      +- foo <----|  |  |
  |  +- 2.0.0/          |  |  |
  |     +- bin/         |  |  |
  |        +- foo <-----|  |  |
  +- bar/                  |  |
     +- 1.2.3/             |  |
     |   +- include/       |  |
     |      +- bar.h       |  |
     |   +- lib/           |  |
     |      +- libbar.so   |  |
     +- 3.0.0/             |  |
        +- include         |  |
        |  +- bar.h <------|  |
        +- lib/               |
           +- libbar.so <-----|
```

This architecture is used by the [Homebrew](https://github.com/Homebrew), [Macports](https://www.macports.org), [Conda](http://conda.pydata.org) and [Nix](https://nixos.org/nix/) package managers.
Homebrew and Macports only allow a single environment to be created, so
are pure rolling releases (though any previous environment can be recreated).
Conda and Nix appear to provide the ability to create as many "environments"
as required, though the author is less familiar with use of these.
The set of packages to be linked into an environment *should* be able
to be handled by packaging scripts (Homebrew "Formulae", Nix "Expresssions")
so that the configuration can recorded through version control and tags.

Whilst the environment can be configured directly to point the `PATH` and
so on to the required linked environment, Homebrew and Nix also
provide tools for direct setup. Rather than directly altering the environment,
a program is run which takes as input a command to be run within a given "environment":

- Homebrew:
  - `brew sh` starts a shell with Homebrew's current environment setup
- Nix:
  - `nix-shell <env> program`

These are analogous to Docker's `run` command. Having a system like this is
strongly favoured as it is cleaner and easier to using than sourcing scripts (it provides clean and isolated startup/teardown). It also gives the same workflow as for Docker containers.

Other Packaging Systems
-----------------------
The RPM/Deb family of tools can also handle the multiple version
structure, though it requires additional care in handling package names.
A potentially useful tool for RPM based packaging is the [Software Collections](https://www.softwarecollections.org/en/) suite. However, this does not use
the link based creation of environments, so will install multiple instances
of the same package version.

Like Homebrew/Nix, Software Collections also provide a 'runner' program
to use tools in the collection directly:

- `scl enable devtoolset-3 bash` would start up a bash shell configured for using the `devtoolset-3` environment

Any program in the collection can be run in similar fashion.



What Software Packaging is Not
==============================
Packaging should not be confused with or coupled to *buildtools* or
*deployment systems*.

Buildtools are the low level tools used for development and to
configure/make/install (e.g. [Autotools](), [CMake]()) a single project.
Packaging systems must be agnostic to these tools and vice versa.
As noted earlier, a very common antipattern is to call the packaging tool inside the buildscripts of a project (e.g. a
`Makefile` calling `rpm` or `yum`). This makes the project unusable on
other systems without adopting the complete package management stack.
In addition, the package manager or buildtool can't be swapped out at a
later date.

Deployment systems include tools like [CVMFS](http://cernvm.cern.ch/portal/filesystem) and [Docker](http://www.docker.com/) (and similar
container systems). Whilst these provide a potentially convenient method
for running software, said software still has to be packaged for installation
in the CVMFS repo or Docker image!


Software Development and Architecture Practices
===============================================
These are practices that a project can use to help make packaging easier,
though are orthogonal to the packaging task itself. Whilst these may seem
obvious, they are noted down because they can cause particular issues
for packaging and tight coupling of tools. Though HSF cannot enforce
  any of these, it *should* document and promote them!

Relocatable Software
--------------------
**Relocatable** means that a package can be moved lock stock from its initial
installation location to anywhere else on the filesystem and still run
*without* user intervention. [OS X Application and Framework Bundles/Packages](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i)
are the classic exemplar of this for programs and libraries respectively, but
the same techniques can be applied across all platforms (the term
'Portable Binary' is often used on Linux). Relocatability is
helpful for packaging as it means that binary packages are easy to implement
without requiring a fixed installation root. It also helps to create the
**Single Rooted** installation structure mentioned above whilst maintaining
correct linking.

It should be noted that whilst environment variables are often used to provide
relocatability, this generally requires reconfiguration by the user and
is thus very fragile to environment misconfiguration. Better tools are
available for implementing relocatability, including

- Relative RPATHs, both on [OS X](http://www.kitware.com/blog/home/post/510) and [Linux](http://linux.die.net/man/8/ld.so)
- Application/Library self-location
  - [binreloc](https://github.com/drbenmorgan/Resourceful) at low level
  - Application objects in frameworks such as [Qt](http://doc.qt.io/qt-5/qcoreapplication.html#applicationDirPath) and [Poco](http://pocoproject.org/docs/Poco.Util.Application.html)


Correct Versioning of ABI/APIs
------------------------------
A significant challenge in packaging is ensuring a set of binaries are
compatible with each other. With C++ being the major language in HEP
computing, this can be especially challenging as many seemingly minor
changes can break the ABI:

- [KDE Document of C++ ABI Issues](https://techbase.kde.org/Policies/Binary_Compatibility_Issues_With_C++)

Having clearly defined version numbers that correctly map to ABI/API changes
really helps to simplify packaging and allows different version of projects
to interoperate easily (and consequently make the packager's life easier).
HSF should provide documentation and education on these issues to help make
HEP software more reliable in this area.

- **Question:** Does anyone have experience with API/ABI compliance checking tools?
- **Question:** Will C++ provide a better [portable ABI](https://isocpp.org/blog/2014/05/n4028) in future?


Support Use of Multiple Versions of Dependent APIs
--------------------------------------------------
Software using a third-party API should, within certain limits, be programmed
to allow for multiple versions of the API. This is generally as simple as
constructs along the lines of

```c++
#include "foo.hpp"

...

int answer(0);

#if FOO_VERSION > 2
// Use new API
answer = newFunction();
#else
answer = oldFunction();
#endif
```

Of course, this ties in with API/ABI versioning above! Like that item, it
helps packagers some freedom in using different versions of projects with
good guarantees on interoperability.


Avoid Micro-packages
--------------------
Modularization of an experiment's software stack is required to create a
sensible division of responsibilities and workload between projects. However,
this must be balanced against the requirement for each project being cohesive
with minimal dependencies on other projects in the stack. HEP software often
over-modularizes, creating issues with dependency management.

Whilst a good package manager (and hence dependency resolver) can help with
installing modular projects, care must be taken to avoid overdependence on it
to solve poor modularization schemes. This is an area that's particularly
vunerable to over-coupling between build and packaging tools.

Useful case studies of modularization include

- [Qt](http://blog.qt.io/blog/2011/01/21/status-of-qt-modularization/)
- [ITK](http://www.itk.org/Wiki/ITK/Release_4/Modularization)
- [KDE](https://community.kde.org/KDE_Core/Modularization)
- [Large Scale C++ Software Design](http://www.amazon.com/Large-Scale-Software-Design-John-Lakos/dp/0201633620), the concept of [Layers](http://en.wikipedia.org/wiki/Layer_%28object-oriented_design%29)


Summary
=======
This has given a very quick brain dump of thoughts on Packaging for HEP.
Further comments, questions and criticisms are welcome, and should be addressed
to the author through the GitHub Issue Tracker on the HSF packaging project.

