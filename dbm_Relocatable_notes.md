Notes on Tools/Techniques for Relocatable Packages
==================================================
This expands on notes already made in [the notes on packaging](dbm_Packaging_notes.md) related to *Relocatable Packages*. Though not an absolute
requirement for packaging, making a project relocatable helps with the
creation and installation of binary packages.

A **Relocatable** project is one in which the contents of the project
(programs, libraries, resource files) can be moved lock stock from its
initial installation location to anywhere else on the filesystem and still
run *without* user intervention. For example, say we initially install a
project `Foo` as follows:

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
          |  |  +- FooConfig.cmake          |
          |  +- pkgconfig/                  |
          |     +- Foo.pc                   |
          +- share/                         |
             +- foo/                        |
                +- resource.xml <------------ reads
```

If `Foo` is relocatable, then we can move it like:

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
             |  |  +- FooConfig.cmake
             |  +- pkgconfig/
             |     +- Foo.pc
             +- share/
                +- foo/
                   +- resource.xml
```

and the user would be able to run `foo-program` without making any changes
either to the files comprising `Foo` or the runtime environment (`PATH`
might be repointed, but `foo-program` would still be runnable via a fully
qualified path). Note that when relocating, the files comprising `Foo` stay
in the same locations relative to each other. Also, we have not considered
the case where `Foo` uses, or is used by, other Projects. However, the
above layout illustrates three aspects of relocatability:

- How does `foo-program` locate its `libfoo.so` dependency at runtime?
- How does `foo-program` locate its `resource.xml` file at runtime?
- How do Foo's CMake and pkg-config support files find libfoo and headers
  when used by a client?

These translate into the technical aspects

- Dynamic library linking/loading with runtime, absolute and relative paths
- Executable self-location on the filesystem
- Script self-location on the filesystem

[OS X Application and Framework Bundles/Packages](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i) are the classic exemplar
of relocatable programs and libraries respectively, but
the same techniques can be applied across all platforms (the term
'Portable Binary' is often used on Linux). Relocatability is
helpful for packaging as it means that binary packages are easy to implement
without requiring a fixed installation root.


Relocatability with Programs and Dynamic Libraries
==================================================
How the dynamic linker/loader works on different platforms. Topics include:

- Dynamic loader paths, including `LD_LIBRARY_PATH` and `RPATH` (`@rpath`
and others on OS X, `$ORIGIN` on Linux), plus Windows DLL search paths.
- Relative RPATHs, both on [OS X](http://www.kitware.com/blog/home/post/510) and [Linux](http://linux.die.net/man/8/ld.so)
- Lookup paths when implementing "Plugin" architectures

Executable Self-Location
========================
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
variable correctly (and knowing to do so). Alternately, `foo-program` could
be wrapped in a shell script that sets this variable using shell-based
self-location. This creates another level of indirection for the user and
may be vulnerable to the same soft/hardlink resolution.

Though C/C++ applications *may* get passed a string *representing* the program name as the zeroth element of the `argv` array:

```C++
int main(int argc, char* argv[])
```

this is not *guaranteed* to be the actual filesystem location of the program (see, for example [this discussion](http://stackoverflow.com/questions/2050961/is-argv0-name-of-executable-an-accepted-standard-or-just-a-common-conventi)).
In particular, the actual invocation of a program may be through a soft or hard link whose
filesystem location is completely separate from that of the executable.
Though links can be followed to some extent, hardlinks in particular cannot
easily be resolved. Rather, most self-location relies on querying the
*process* itself.

Some basic techniques, but also APIs including

- [binreloc](https://github.com/drbenmorgan/Resourceful) at low level
- Application objects in frameworks such as [Qt](http://doc.qt.io/qt-5/qcoreapplication.html#applicationDirPath) and [Poco](http://pocoproject.org/docs/Poco.Util.Application.html)

Other languages may have different techniques or builtin tools (see below).

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
    systems (e.g. Homebrew's sh/superenv or Nix environments for example).

However, this is not neccessarily a complete solution.

Pkg-Config
---------
Scripts for the [pkg-config](http://www.freedesktop.org/wiki/Software/pkg-config/)
tool can also be made relocatable by using the builtin `pcfiledir` variable.
This expands to the directpory holding the `.pc` file, and so for our
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
