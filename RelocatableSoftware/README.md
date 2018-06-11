Relocatable Software: Issues, Tools and Techniques
==================================================
A **Relocatable** software package is one in which a package
(collection of programs, libraries, resource files) can be moved lock stock from its
initial installation location to anywhere else on the filesystem and still
run *without* user intervention. Implementing this ability in software
provides several benefits, including

- Minimal setup for end users, as they do not need to set package-specific
  environment variables or edit configuration files
- Easier binary packaging and deployment, as binaries do not require
  installation at the same location either at install or use time (e.g.
  NFS/AFS/CVMFS mount point)

This document describes some of the issues that arise in making relocatable
software packages from the source code to binary packaging level, and
discusses tools and techniques to help the developer and end user. Several
example projects in C++ and Python are provided as illustrations of the
techniques. Whilst primarily concerned with the "front line" programming languages
used in HEP (C, C++ and Python), it is open to comments and examples
from other languages in use or under consideration.

What is Relocatability?
=======================
Say we have installed a package `SLPackage` that comprises a program, library, plugins, and
resource files:

```
/home/
 +- user/
    +- Projects/
       +- SLPackage/
          +- bin/
          |  +- slp_program >------------------- >---
          +- include/                          |    |
          |  +- slp.h                          |    |
          +- lib/                              |    |
          |  +- libslp.so <----------- links to     |
          |  +- plugins/     |                      |
          |  |  +- a.so    <-|                      |
          |  |  +- b.so    <-| loads                |
          |  +- cmake/                              |
          |  |  +- SLPackage/                       |
          |  |     +- SLPackageConfig.cmake         |
          |  +- pkgconfig/                          |
          |     +- SLPackage.pc                     |
          +- share/                                 |
             +- SLPackage/                          |
                +- resource.txt <-------------- reads
```

If `SLPackage` is relocatable, then we can move it across the filesystem, e.g.:

```
$ mv /home/user/Projects/SLPackage /home/user/Another/Workspace
...

/home/
 +- user/
    +- Another/
       +- Workspace/
          +- SLPackage/
             +- bin/
             |  +- slp_program
             +- include/
             |  +- slp.h
             +- lib/
             |  +- libslp.so
             |  +- plugins/
             |  |  +- a.so
             |  |  +- b.so
             |  +- cmake/
             |  |  +- SLPackage/
             |  |     +- SLPackageConfig.cmake
             |  +- pkgconfig/
             |     +- SLPackage.pc
             +- share/
                +- SLPackage/
                   +- resource.txt
```

and the user would be able to run `slp_program` or link to `libslp` without making *any* changes
to either the files comprising `SLPackage` or the runtime environment (`PATH`
might be edited for convenience, but `slp_program` would still be runnable via a fully
qualified path). _Note that the relocation keeps the files comprising
`SLPackage` in the same locations relative to each other_.
[OS X Application and Framework Bundles/Packages](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i)
are the classic example of relocatable programs and libraries respectively, and
the term 'Portable Binary' is often used on Linux.

Though basic, this example illustrates three of the core issues of relocatability and
the corresponding technical aspects:

- **How does `slp_program` locate its dynamic library `libslp.so` dependency at runtime?**
  - _Link/Run time lookup of dynamic libraries_
- **How does `slp_program` locate its `resource.txt` file, or `libslp` its `plugin`s at runtime?**
  - [_Binaries able to self-locate themselves on the filesystem at runtime_](SLPackage)
- **How do `SLPackage`'s CMake, pkg-config, and other support files find `SLPackage`'s library and headers
  when used by a client?**
  - [_Script self-location on the filesystem at runtime_](DevTools)

A further item to be considered is what happens if `SLPackage` uses files
from another package (e.g. `slp_program` or `libslp` links to a "`libbar`").
This is deferred to a later section.

Whilst the example only illustrates moving a package across a local
filesystem, it is equally valid for moves across network filesystems with
different mount points or even between different systems. Of course the package is then only usable if the
OS/toolchain mounting the filesystem is the same, or binary compatible
with, the OS/toolchain the package was built for. Though not a direct
issue for relocatability, programming and compiling for binary
compatibility is helpful for simplifying binary packaging and deployment.
The issues here include:

- Software development
  - Mostly a training/policy issue for individual projects (but perhaps HSF can help)
  - Clear and well-managed API/ABI versioning, especially for compiled languages
    - Ensures software can be used by as wide a range of upstream clients as possible
    - Nevertheless, can be tricky for [languages like C++](https://community.kde.org/Policies/Binary_Compatibility_Issues_With_C%2B%2B)
    - There [are tools to help check compatibility](https://fedoraproject.org/wiki/How_to_check_for_ABI_changes_in_a_package) at least for ELF, but needs a more thorough survey.
  - Program for compatibility with multiple versions of any dependencies
    - Dependencies should provide a versioning header [as per HSF (draft) guidelines](https://github.com/HEP-SF/documents/blob/master/HSF-TN/draft-2016-PROJ/draft-HSF-TN-2016-PROJ.md)
  - Hide dependencies as implementation details as far as possible.
  - Consider versioned symbols and/or inlined namespaces?
- Building binaries
  - Policy issue for packager(s).
  - Target minimal system API/ABI, e.g. `-mmacosx-min-version` on OS X or build for suitable
    minimum `glibc` on Linux.
  - On Linux, consider "standalone" toolkit of glibc, binutils, gcc (c.f. Nix, Portage, Linuxbrew package managers)

(Re)Locating the Interpreter for Programs
=========================================
Programs implemented using intepreted languages such as Python are usually written as scripts using (on Unix platforms)
a ["shebang"](https://en.wikipedia.org/wiki/Shebang_(Unix)) on the first line to define the interpreter program to pass the remainder of the script to. For example, a Python "hello world" program might be written as

```Python
#!/usr/bin/python

print("hello world")
```

This hard codes the system interpreter into the program and whilst this program is relocatable (assuming a valid system
Python install), it cannot be used with any other interpreter. Typical HEP software stacks install, and require use of,
their own interpreters, whose paths may also end up hard coded into scripts:

```Python
#!/custom/stack/root/python/2.7/bin/python

print("hello world")
```

The resulting stack is then not relocatable as the interpreter path will not exist after relocation.

Rather than hard coding system or custom interpreter paths, script authors should prefer the use of the
[`env`](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/env.html) program as the shebang, e.g.

```Python
#!/usr/bin/env python

print("hello world")
```

Use of `env` makes the program relocatble, but defers location of the interpreter to the `PATH` environment variable,
and consequently the configuration management system for the software stack. Whilst package authors should prefer
usage of the `env` pattern, software stack managers can also consider rewriting the shebang line during install
and on any relocation to the absolute path of the required interpreter. As it is plain text, simple regular expression
replacement can be used, but the chosen packaging system must support this, and care must be taken
if the resultant stack is to be deployed over network file systems (and hence unknown mount points).

**TODO?** Binaries *also* have an interpreter (on Linux, `ld-linux.so`, On macOS, `dyld`). These are also hardcoded,
though can be changed with, e.g., `patchelf` for ELF binaries.


(Re)Locating Dynamic Libraries
==============================
A non-trivial package will usually be partioned into a main
program/libraries linking to 1-N internal, plus 0-M external, libraries.
For [static libraries/linking](https://en.wikipedia.org/wiki/Static_library), the libraries only need locating at build/link time.
When [dynamic/shared libraries](https://en.wikipedia.org/wiki/Dynamic_linker)
are used, client programs/libraries must locate the needed libraries at
both build/link and *run* times, and it is this run time location
that is discussed here.

**TODO**: How the dynamic linker/loader works on different platforms. Topics include:

- Dynamic loader paths, including `LD_LIBRARY_PATH`, `RPATH` and `RUNPATH` (inc. `@rpath`
and others on OS X, `$ORIGIN` on Linux), plus Windows DLL search paths.
- Relative RPATHs, both on [OS X](http://www.kitware.com/blog/home/post/510) and [Linux](http://linux.die.net/man/8/ld.so)
- Lookup paths when implementing "Plugin" architectures (i.e. loading dynamic libraries into an already running program)

Dynamic programs and libraries can be queried by system tools to display what they link to and how these paths are resolved.
To query what a dynamic executable links to, the commands

```console
... Linux ...
$ ldd <dynamicexecutable>

... OS X ...
$ otool -L <dynamicexecutable>
```

may be used. Additionally, detailed runtime information on how the dynamic linker/loader resolves links when loading/running the program can be obtained by setting platform specific environment variables, e.g.

```console
... Linux ...
$ LD_DEBUG=all <program>

... OS X ...
$ export DYLD_PRINT_LIBRARIES=1
$ export DYLD_PRINT_RPATHS=1
$ <program>
```

These can be useful for tracing runtime issues. See the `ld.so/ld-linux.so` (Linux) or `dyld` (OS X) `man` pages for additional details.

**TODO**: Remember to document the odd difference in behaviour of `$ORIGIN` between link and run times. Basically, it appears that binutils `ld` *does not* expand it at link time, which can result in error messages about needing `-rpath-link`. This *appears* to be a [missing feature or bug in binutils](https://sourceware.org/bugzilla/show_bug.cgi?id=16936)

**TODO**: Behaviour of tools of as CMake and Autotools, which encode
the rpath into the locally built binaries by default. This enables them
to be run directly for testing and guarantees that they will find their
dependencies. At install time, rpaths are usually stripped, unless
configured otherwise.


(Re)Locating Language Modules
=============================
**TODO** How to handle module lookup, e.g. `PYTHONPATH` for Python (other languages?). Things that package authors can do.
Things that the packaging system should do (inc. any packaging system provided by the language, e.g. `pip`, `virtualenv`).
Things best left to configuration management.




Relocatability with External Dependencies
=========================================

What happens to relocatability when we have two packages with a dependency?
For example `Foo` and `Bar`, with `Foo` linking to `libbar` from `Bar`.

1. Can move `Foo` if its `RPATH` contains absolute path to `libbar`.
2. Cannot move `Bar` without updating `Foo`'s RPATH or using/updating dynamic
   loader paths
3. Can move both `Foo` and `Bar` provided relative RPATHs
   are used and both stay in the same locations relative to each other.

**TODO**: Cases for text/resource file dependencies?



Patching Upstream Software
==========================
The preceeding sections cover cases where "we" are developing the
software, or have identified relocatability issues and are in a
position to patch these. Typical HEP software
stacks will use a large number of packages not directly maintained by
the experiment/community using them, and not all of them may meet the
criteria for full relocatability. How to handle these?

In the first instance, a feature request should always be put in with the
upstream maintainers. Other techniques for patching are discussed
below.

Self-Location
-------------
If a program uses environment variables to set paths for resource
location, then one way to non-intrusively patch this is to create
a self-locating Bash/Python script wrapping the actual executable.
The script can contain the derived relative path(s) needed and set
these at runtime before executing the actual program, forwarding any
additional arguments.

For libraries using environment variables, it may be possible to wrap
these with a small facade library. This would do nothing more that
self-locate, set the needed environment variables and expose the rest
of the library symbols. However, this has implications for usability
and runtime manipulation of the environment by clients.

When absolute paths are hardcoded into binaries, then only intrusive
patching is likely to work. For simple cases, application of the
techniques discussed earlier may be able to provide a fully relocatable
solution. At worst, hard coded paths could be replaced with environment
variable lookup and wrapper scripts. In more complex cases, it may be possible to patch the
binary directly at install time (**TODO**: tools for this?) to
rewrite hardcoded paths. Note that this still results in hard coded
paths, so can only really be handled by a package manager system and would
not work for deploying software over network file systems where final
mount points are not guaranteed to be identical.

Interpreter Paths
-----------------
Shebangs are plain text, so are straightforward to patch directly using regular expression
find/replace directly, or via tooling at build or install time.

Library RPATHs
--------------
1. RPATHs can be changed at install time by the packaging system/tools (`patchelf`, `otool`, `install_name_tool` etc)
2. Runtime/chroot based tools like [PRoot](https://github.com/proot-me/PRoot/blob/master/doc/proot/manual.txt) may
also be useful.


Relocation and Packaging
========================
**TODO** Topics involving relocatability when it comes to the packaging level. Define "packaging" as the things we need
to do/write to allow `spack|brew|whatever install mypackage` to work, whether building `mypackage` from source locally
or downloading and unpacking a binary. The "package manager" needs to include tooling to manage relocation, and this
may include things like changing RPATHs in binaries, to shebangs in interpreted programs. Other topics like deployment
to CVMFS etc.

Take simple example of two packages and a "typical" versioned tree plus "views"? e.g.

```
+- whateverroot/
   +- packages/
   |   +- Foo/
   |   |  +- 1.0/
   |   |  |   +- bin/
   |   |  |   +- lib/
   |   |  |   +- ...
   |   |  +- 2.0/
   |   |     +- ...
   |   +- Bar/
   |      +- 1.0-usingFoo1.0/
   |      |  +- bin/
   |      |  +- lib/
   |      +- 1.0-usingFoo2.0/
   |         +- bin/
   |         +- lib/
   +- views/
      +- release-1.0/
      |  +- bin/
      |  +- lib/
      +- release-2.0/
         +- bin/
         +- lib/
```

Assume Foo/Bar are relocatable according to earlier topics, how should package manager deal with pointing Bar to its
needed Foo, and how do views work in this case?


Conclusions
===========
**TODO**



