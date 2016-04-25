Relocatable
===========
Example program/library code to demonstrate package relocatability concepts.
The following software is required to build the base set of programs:

- [CMake](https://www.cmake.org) version 3.3 or newer
- C++11 compatible compiler (GNU, Clang, Intel, MSVC)

The following software is optional:

- [Qt5](https://www.qt.io) for the [qt](qt) subproject
- [Poco](http://pocoproject.org) for the [poco](poco) subproject

To build the software, simply create a build directory and run `cmake` inside it,
pointing it to the top level source directory (i.e. the directory holding this
README):

```console
$ ls
CMakeLists.txt README.md binreloc       poco           qt
$ mkdir build
$ cd build
$ cmake ..
$ cmake --build .
```

If CMake has issues finding any dependencies, ensure their root install prefixes
are listed in `CMAKE_PREFIX_PATH` and passing this list to `cmake` on the command 
line or setting it in your environment.

Build Outputs
=============
All build products are output under the `BuildProducts` subdirectory of the build 
directory. This contains a hierarchy intended to match the install layout, but note
that there is no `install` target at present.

If you configure the project for an IDE like Xcode, the `BuildProducts` directory will
contain an extra level of directories to support each build type (`Release`, `Debug` etc)





