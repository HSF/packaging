Relocatability and Development Tools
====================================
This looks at relocatability of/in files that a package may install for
use by other packages that use, and thus develop against, it. It therefore
focuses on the HEP case of C/C++/Fortran libraries that use, and are used by,
other libraries.

CMake
=====
To support use of a Project by a CMake based client project, scripts for
use with CMake's [`find_package`](http://www.cmake.org/cmake/help/v3.2/command/find_package.html) command in "config"
mode should be provided. A `FindPACKAGENAME.cmake` should *not* be implemented, including the use of CMake commands
like `find_path`, `find_library` as these are intended to locate packages not supplying any CMake support files. CMake
"ProjectConfig.cmake" files are installed alongside the project and can self-locate the project's headers/libraries/executables
without having to find anything.

If the Project itself is built with CMake, "ProjectConfig.cmake" files are very easy to create
via the [`CMakePackageConfigHelpers`](http://www.cmake.org/cmake/help/v3.2/module/CMakePackageConfigHelpers.html) module
and the [`install`](http://www.cmake.org/cmake/help/v3.2/command/install.html) command's `EXPORT` signature.
These make use of CMake's [imported targets](http://www.cmake.org/cmake/help/v3.2/command/add_library.html?#imported-libraries) and the ability for CMake scripts to self-locate themselves (e.g. [`CMAKE_CURRENT_LIST_FILE`](https://cmake.org/cmake/help/v3.2/variable/CMAKE_CURRENT_LIST_FILE.html)to allow the resultant "ProjectConfig.cmake" file(s)
to be completely relocatable.

Creating and managing these files can become more complicated with Projects that depend on others.
Generally, this can be handled with

- Consistent use of imported targets to avoid hard-coding paths to dependent libraries/headers
- Minimizing public link dependencies, as these must be refound, even if the client does not use the dependency directly
- "ProjectConfig.cmake" files should call `find_package` for any compile or link time dependencies. This
  refinds any dependencies and hence creates the required imported targets. How the dependencies are located
  by `find_package` should be left to the configuration management system, which can point CMake to
  the right locations using the standard CMake command line/environment variables such as [`CMAKE_PREFIX_PATH`](http://www.cmake.org/cmake/help/v3.2/variable/CMAKE_PREFIX_PATH.html)
  - This also works for build wrapper systems (e.g. spack's env setup, Homebrew's sh/superenv or Nix environments for example).

However, this is not necessarily a complete solution.

Pkg-Config
==========
Scripts for the [pkg-config](http://www.freedesktop.org/wiki/Software/pkg-config/)
tool can also be made relocatable by using the builtin `pcfiledir` variable.
This expands to the directory holding the `.pc` file, and so for an
example project Foo this could be written as

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
As with CMake, this should be handled by the configuration management or
build wrapper.

Other tools
===========
**TODO**: Autotools (though probably via `pkg-config`), SCons, others, Python packaging.

