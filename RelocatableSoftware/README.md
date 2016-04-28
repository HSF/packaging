Relocatable Software: Issues, Tools and Techniques
==================================================
A **Relocatable** software package is one in which the contents of the package
(programs, libraries, resource files) can be moved lock stock from its
initial installation location to anywhere else on the filesystem and still
run *without* user intervention. Implementing this ability in software
provides several benefits, including

- Minimal setup for end users, as they do not need to set package-specific
  environment variables or edit configuration files
- Easier binary packaging and deployment, as binaries do not require
  installation at the same location either at install or use time (e.g.
  NFS/AFS/CVMFS mount point)

This document describes the issues that arise in implementing relocatability
in software packages from the source code to binary packaging level, and 
discusses tools and techniques to help the developer and end user. Several
example projects in C++ and Python are provided as illustrations.
Whilst primarily concerned with the "front line" programming languages
used in HEP (C, C++ and Python), it is open to comments and examples
from others in use or under consideration.

What is Relocatability?
=======================
Say we install a package `Foo` that comprises a program, library and
resource files:

```
/home/
 +- user/
    +- Projects/
       +- Foo/
          +- bin/
          |  +- foo-program <-- <------------
          +- include/         |             |
          |  +- foo.h         |             |
          +- lib/             |             |
          |  +- libfoo.so <---- links to    |
          |  +- cmake/                      |
          |  |  +- Foo/                     |
          |  |     +- FooConfig.cmake       |
          |  +- pkgconfig/                  |
          |     +- Foo.pc                   |
          +- share/                         |
             +- foo/                        |
                +- resource.xml <------------ reads
```

If `Foo` is relocatable, then we can move its contents across the filesystem, e.g.:

```
$ mv /home/user/Projects/Foo /home/user/Another/Workspace
...

/home/
 +- user/
    +- Another/
       +- Workspace/
          +- Foo/
             +- bin/
             |  +- foo-program
             +- include/
             |  +- foo.h
             +- lib/
             |  +- libfoo.so
             |  +- cmake/
             |  |  +- Foo/
             |  |     +- FooConfig.cmake
             |  +- pkgconfig/
             |     +- Foo.pc
             +- share/
                +- foo/
                   +- resource.xml
```

and the user would be able to run `foo-program` without making *any* changes
either to the files comprising `Foo` or the runtime environment (`PATH`
might be edited for convenience, but `foo-program` would still be runnable via a fully
qualified path). Note that the relocation keeps the files comprising `Foo`
in the same locations relative to each other. 
[OS X Application and Framework Bundles/Packages](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i) 
are the classic exemplar of relocatable programs and libraries respectively, and
the term 'Portable Binary' is often used on Linux. 

Though basic, this example illustrates three of the core issues of relocatability and
the corresponding technical aspects:

- How does `foo-program` locate its dynamic library `libfoo.so` dependency at runtime?
  - Link/Run time lookup of dynamic libraries
- How does `foo-program` locate its `resource.xml` file at runtime?
  - Executable self-location on the filesystem at runtime
- How do Foo's CMake and pkg-config support files find `Foo`'s library and headers
  when used by a client?
  - Script self-location on the filesystem at runtime

A further item to be considered is what happens if `Foo` uses files from another
package (e.g. `foo-program` links to "`libbar`"). This is deferred to a later section.

Whilst the example only illustrates moving a package across a local filesystem, it is
equally valid for moves across network filesystems with different mount points.
Of course the package is then only usable if the OS/toolchain mounting the filesystem is
the same, or binary compatible with, the OS/toolchain the package was built for. Though
not a direct issue for relocatability, programming and compiling for binary compatibility
are helpful for simplifying binary packaging and deployment. The issues here
include:

- Software development
  - Mostly a training/policy issue for individual projects (but perhaps HSF can help) 
  - Clear and well-managed API/ABI versioning, especially for compiled languages
    - Ensures software can be used by as wide a range of upstream clients as possible
    - Nevertheless, can be tricky for [languages like C++](https://community.kde.org/Policies/Binary_Compatibility_Issues_With_C%2B%2B)
    - There [are tools to help check compatibility](https://fedoraproject.org/wiki/How_to_check_for_ABI_changes_in_a_package) at least for ELF, but needs a more thorough survey.
  - Program for multiple versions of any dependencies (assumes they have good API/ABI versioning!!)
    - Dependecies should provide a versioning header [as per HSF (draft) guidelines](https://github.com/HEP-SF/documents/blob/master/HSF-TN/draft-2016-PROJ/draft-HSF-TN-2016-PROJ.md)
  - Hide dependencies as implementation details as far as possible.
  - Consider versioned symbols and/or inlined namespaces?
- Building binaries
  - Policy issue for packager(s). 
  - Target minimal system API/ABI, e.g. `-mmacosx-min-version` on OS X or build for suitable
    minimum glibc on Linux.
  - On Linux, consider "standalone" toolkit of glibc, binutils, gcc.


(Re)Locating Dynamic Libraries
==============================
How the dynamic linker/loader works on different platforms. Topics include:

- Dynamic loader paths, including `LD_LIBRARY_PATH`, `RPATH` and `RUNPATH` (inc. `@rpath`
and others on OS X, `$ORIGIN` on Linux), plus Windows DLL search paths.
- Relative RPATHs, both on [OS X](http://www.kitware.com/blog/home/post/510) and [Linux](http://linux.die.net/man/8/ld.so)
- Lookup paths when implementing "Plugin" architectures

**NOTE**: Remember to document the odd difference in behaviour of `$ORIGIN` between link and run times. Basically, it appears that binutils `ld` *does not* expand it at link time, which can result in error messages about needing `-rpath-link`. This *appears* to be a [missing feature or bug in binutils](https://sourceware.org/bugzilla/show_bug.cgi?id=16936)

Self-Location of Compiled and Interpreted Executables
=====================================================
How can a program or library introspect itself to find out where on the
filesystem it was loaded from? If we know this location, then default
resource files and search paths can easily be derived from known relative
locations. For example, say the `Foo` application is written in C++
and uses a `resource.xml` file:

```
+- <PREFIX>
   +- bin/
   |  +- foo-program
   +- share/
      +- foo/
         +- resource.xml
```

A typical solution to locating `resource.xml` would be to use an
environment variable and query this in the program:

```C++
const char* resourcePath = getenv("FOO_RESOURCE_PATH");
```

Whilst this does enable relocatability, it relies on the user setting this
variable correctly, knowing to do so, and changing it if the package is moved. 
Alternately, `foo-program` could be wrapped in a shell script that sets this 
variable using shell-based self-location. This creates another level of 
indirection for the user and may be vulnerable to the same soft/hardlink resolution.

Though C/C++ applications *may* get passed a string *representing* the program name as the zeroth element of the `argv` array:

```C++
int main(int argc, char* argv[]) {
  std::cout << argv[0] << "\n";
}
```

it is not *guaranteed* to be the actual filesystem location of the program 
(see, for example 
[this discussion](http://stackoverflow.com/questions/2050961/is-argv0-name-of-executable-an-accepted-standard-or-just-a-common-conventi)
).
In particular, the actual invocation of a program may be through a soft or hard link whose
filesystem location is completely separate from that of the executable.
Though links can be followed to some extent, hardlinks in particular cannot
easily be resolved. Rather, most self-location relies on querying the
*process* itself.

Some basic techniques, but also APIs, are demonstrated in the [`Relocatable`](Relocatable)
example project, including

- [binreloc](https://github.com/drbenmorgan/Resourceful) at low level for C/C++
- Application objects in frameworks such as 
  [Qt](http://doc.qt.io/qt-5/qcoreapplication.html#applicationDirPath)
  [Poco](http://pocoproject.org/docs/Poco.Util.Application.html) for C/C++
- Techniques from Python and Ruby interpreted languages.

There are some paths to resource files that, depending on exact use case, may require 
hard-coding or use of standard environment variables. On UNIX, these could include

- `/etc`
- `/var`
- `/tmp` or `TMPDIR`


Scripting/Development Support Tools
===================================
CMake
-----
To support use of a Project by a CMake based client project, scripts for
use with CMake's [`find_package`](http://www.cmake.org/cmake/help/v3.2/command/find_package.html) command in "config" mode should be provided.
If the Project itself is built with CMake, these are very easy to create
in using the [`CMakePackageConfigHelpers`](http://www.cmake.org/cmake/help/v3.2/module/CMakePackageConfigHelpers.html) module
and the [`install`](http://www.cmake.org/cmake/help/v3.2/command/install.html) command's `EXPORT` signature.
These make use of CMake's [imported targets](http://www.cmake.org/cmake/help/v3.2/command/add_library.html?#imported-libraries) and the ability for
scripts to self-locate to allow the resultant "ProjectConfig.cmake" file(s)
to be completely relocatable.

This can become more complicated with Projects that depend on others.
Generally, this can be handled with

- Consistent use of imported targets
- Minimizing public link dependencies
- "ProjectConfig.cmake" files should call `find_package` for any compile
or link time dependencies.
  - The standard CMake command line/environment variables such as [`CMAKE_PREFIX_PATH`](http://www.cmake.org/cmake/help/v3.2/variable/CMAKE_PREFIX_PATH.html) should used to point CMake to the right search prefixes
  - That can be handled by the configuration management or build wrapper
    systems (e.g. spack's env setup, Homebrew's sh/superenv or Nix environments for example).

However, this is not necessarily a complete solution.

Pkg-Config
---------
Scripts for the [pkg-config](http://www.freedesktop.org/wiki/Software/pkg-config/)
tool can also be made relocatable by using the builtin `pcfiledir` variable.
This expands to the directory holding the `.pc` file, and so for our
example project Foo could be written as

```
prefix=${pcfiledir}/../..
libdir=${prefix}/lib
includedir=${prefix}/include

Name: Foo
Libs: -L${libdir} -lfoo
Cflags: -I${includedir}
```

Here the relative path from `pcfiledir` to the prefix and the relative
`lib` and `include` paths have been hand written for clarity, but can easily
be created from expansion variables set by the buildsystem of Foo.

Pkg-config can also handled dependencies, and the `PKG_CONFIG_PATH` (and possibly `PKG_CONFIG_LIBDIR`)
environment variable should be used to correctly resolves paths to these.
As with CMake, this could be handled by the configuration management or
build wrapper.

Other tools?
------------
?

Linked Relocatability
=====================
What happens to relocatability when we have two packages with a dependency?
For example `Foo` and `Bar`, with `Foo` linking to `libbar` from `Bar`.

1. Can move `Foo` if its `RPATH` contains absolute path to `libbar`.
2. Cannot move `Bar` without updating `Foo`'s RPATH or using dynamic
   loader paths
3. Can package and deploy both `Foo` and `Bar` provided relative RPATHs
   are used and both stay in the same relative location to each other.

Also consider case of text/resource file dependency.


Other Languages
===============
Above focuses on compiled C/C++, but will have packages using other
languages (Python for example). These will have their own, and often
much easier, methods for lookup of dependencies and self-location.
They may also provide builtin support for resource files and other things.
Provide some examples of this.

Bash
----
For an executable script, it can be located using the `readlink` command on
the `$0` argument, though this does not resolve hardlinks. Whilst GNU
`readlink` can fully traverse softlinks using the `-f` argument, this is not
portable.

```Bash
# GNU readlink only
selfLocation=$(readlink -f $0)
```

For `readlink` implementations not supporting the `-f` argument, workarounds
are needed. Deepending on the platform, these may vary from using Python
(!, though not unreasonable on OS X platforms) to pure Bash/Sh implementations.
The latter basically involve iterating over any sequence of symlinks.
A discussion on this with example implementations is [covered on StackOverflow](http://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac)

Python
------
Current file:

```Python
import os
selfLocation = os.path.realpath(__file__)
```

Ruby
----
Current file:

```Ruby
selfLocation = File.expand_path(__FILE__)
```

Go
--
Information from [Sebastien Binet](https://github.com/sbinet)

> As you put a 'go' section in your brain dump, I feel compelled to pipe in :)
>
> go programs are statically linked (at least the pure-go ones) so the
> issue of locating DSOs is moot.
>
> for other resources, the canonical way is to compile the assets inside
> the binary:
>
> https://github.com/jteeuwen/go-bindata
>
> or locate them from $GOPATH (the $PYTHONPATH for Go):
>
> https://github.com/hwaf/gas


Others?
-------
?

Patching Upstream Software
==========================
The preceeding sections cover cases where "we" are developing the software, or are in a position
to easily patch it. Typical HEP software stacks will use a large number of packages not
directly maintained by the experiment/community using them, and not all of them may meet the
criteria for full relocatability. How to handle these?

1. If only RPATHs or text files are involved, these should(?) be handled by the packaging system/tools (`patchelf`, `otool`, `install_name_tool` etc)
2. If paths are hard-coded in binary files, and patching in, say, binreloc support isn't supported, 
   it may be possible to patch the binary file directly. TODO: is this possible? what tools are there? can these be integrated in packaging/deplyment systems?
   - Note however that this is still results in a hard-coded path rather than one derived at runtime.
3. Runtime/chroot based tools like [PRoot](https://github.com/proot-me/PRoot/blob/master/doc/proot/manual.txt)?

