SLPackage
===========
Example program/library code to demonstrate package relocatability concepts.
The following software is required to build the base set of programs:

- [CMake](https://www.cmake.org) version 3.3 or newer
- C++11 compatible compiler (GNU, Clang, Intel)
- macOS or Linux OS (Windows not yet supported)

The following software is optional:

- [Qt5](https://www.qt.io) for the [qt](programs/slp_program-qt.cpp) example application
- [Poco](http://pocoproject.org) for the [poco](slp_program-poco.cpp) example application

To build the software, simply create a build directory and run `cmake` inside it,
pointing it to the top level source directory (i.e. the directory holding this
README):

```console
$ ls
CMakeLists.txt README.md      slp_program       programs       scripting
$ mkdir build
$ cd build
$ cmake ..
$ cmake --build .
```

If CMake has issues finding any dependencies, ensure their root install
prefixes are listed in `CMAKE_PREFIX_PATH` and pass this list to
`cmake` on the command line or setting it in your environment.

Build Outputs
=============
All build products are output under the `BuildProducts` subdirectory of
the build directory. This contains a hierarchy intended to match the
install layout, but note that there is no `install` target at present.

If you configure the project for an IDE like Xcode,
the `BuildProducts` directory will contain an extra level of directories
to support each build type (`Release`, `Debug` etc)


Compiled Languages
==================
The [programs](programs) directory focuses on C/C++ implementations, but PRs are
welcome to demonstrate application/library self-location in other languages.

The `slp_program` program
----------------------

This basic C/C++ example demonstrates the use of the [`binreloc`](programs/binreloc)
library for simple application self-location. It also comes with a basic resource
file "resource.txt" to show how these can be located. Simply running the application
will print its location and the contents of the resource file:

``` console
$ ./BuildProducts/bin/slp_program
[application in]: /AbsPathToWhereYouRanCMake/./BuildProducts/bin
[resource]: 'hello from builtin slp_program resource file!
'
$
```

Relocatability can be tested by copying the `BuildProducts` directory to any other location
you like on the local machine. Rerun `slp_program` and it should print its new location and
the resource contents. You can prove that it's not using build time paths by removing
the original build directory.


The `slp_program-poco` program
---------------------------

Demonstrates the self-location interfaces supplied by the [Poco](http://pocoproject.org) libraries.


The `slp_program-qt` program
-------------------------

Demonstrates the self-location interfaces supplied by the [Qt5](https://www.qt.io) libraries.


Scripting Languages
===================
The directories under [scripting](scripting) contain (very) basic
examples of relocatable Python and Ruby programs. If your language du jour
is not in here, feel free to add a PR showing how it implements self-location.


Dealing with Packaging Issues
=============================

When implementing new or patching existing HEP packages, the above techniques
should ensure relocatablity. Packaging involves integrating many pieces of software,
many of which may not be fully relocatable. This section aims to provide demonstrations
of the typical cases and fixes where possible (and "this is broken" where not...).
Examples are:

1. A program/library links to others - use of `patchelf` and `install_name_tool`, RPATHS,
   RUNPATHS, and linker tricks.
2. A program/library hard codes a path into binary. For example

   ``` c
   /* bad.cc */
   #define RESOURCEPATH /usr/share/badpackage
   ```

   Likely to be the most awkward case, but conda/spack may have the tools to repoint these
   paths.
3. A package has text based files that hard code paths, e.g.

   ``` sh
   #!/some/build/time/path/to/python
   ```

   Simple search-and-replace should work here.


STUFF FROM TOP-LEVEL README IMPORTED BELOW
==========================================
Self-Location of Compiled and Interpreted Executables
=====================================================
How can a program or library introspect itself when running to find out where on the
filesystem it was loaded from? If we know this location, then default
resource files and search paths can easily be derived from known relative
locations. For example, say the `Foo` application is written in C++
and uses a `resource.txt` file:

```
+- <PREFIX>
   +- bin/
   |  +- slp_program
   +- share/
      +- slp_program/
         +- resource.txt
```

A typical solution to locating `resource.txt` at runtime would be to use an
environment variable and query this in the program, e.g. in C/C++:

```C++
const char* resourcePath = getenv("SLPACKAGE_RESOURCE_PATH");
```

Whilst this does enable relocatability, it relies on the user setting this
variable correctly, knowing to do so, and changing it if the package is
moved. It is easier if the binary can introspect itself at runtime
to determine where on the filesystem its physical file is stored - this
is _self-location_. Using this information, the path to the `resource.txt`
file can be determined by joining the binary file path with the
_relative path_ from it to the resource file. Here, the relative path is known
at compile/install time so is hard-coded into the binary, but because
it is relative, the "bundle" of binary and resource may be freely
moved together without invalidating the relative path between the files.

There are various language dependent techniques to implement
self-location in applications and libraries. Self-locating *resources*
(e.g. `A.txt` "loads" `../extra/B.txt` in a hierarchical system) is
outside the scope of this document as it is highly implementation
dependent. The sections below describe
the minimal (as far as is known) code needed to obtain the location
of the currently executing program or library for a handful of languages,
and additions are welcome. Note that languages may have additional
builtins or simple extensions to handle either self-location or the
specific use case of locating resource files (e.g., see the notes
on the Go language below).

Python
------
The full path to the current file is easily obtained using the `os`
module:

```Python
import os
selfLocation = os.path.realpath(__file__)
```

This is equally valid for programs, modules and packages.

Ruby
----
Ruby's construct is very similar to Python, using the `File` builtin

```Ruby
selfLocation = File.expand_path(__FILE__)
```

This should be equally valid for programs and gems/packages.

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

Bash
----
An executable script can be located using the `readlink` command on
the `$0` command line argument, though this does not resolve hardlinks.
Whilst GNU `readlink` can fully traverse softlinks using the `-f`
argument, this is not portable.

```Bash
# GNU readlink only
selfLocation=$(readlink -f $0)
```

For `readlink` implementations not supporting the `-f` argument,
workarounds are needed. Depending on the platform, these may vary from
using Python (!, though not unreasonable on OS X platforms) to pure
Bash/Sh implementations. The latter basically involve iterating over any
sequence of symlinks. A discussion on this with example implementations is [covered on StackOverflow](http://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac)


C/C++
-----
Though C/C++ applications *may* get passed a string *representing* the program name as the zeroth element of the `argv` argument to `main`:

```C++
int main(int argc, char* argv[]) {
  std::cout << argv[0] << "\n";
}
```

this is not *guaranteed* to be the actual filesystem location of the program
(see, for example
[this discussion](http://stackoverflow.com/questions/2050961/is-argv0-name-of-executable-an-accepted-standard-or-just-a-common-conventi)
).
In particular, the actual invocation of a program may be through a soft or hard link whose
filesystem location is completely separate from that of the executable.
Though links can be followed to some extent, hardlinks in particular cannot
easily be resolved. Rather, most self-location relies on querying the
*process* itself.

Some basic techniques, but also APIs, are demonstrated in the [`SLPackage`](SLPackage`) example project, including

- [binreloc](https://github.com/drbenmorgan/Resourceful) at low level for C/C++
- C++ Application objects in frameworks such as:
  - [Qt](http://doc.qt.io/qt-5/qcoreapplication.html#applicationDirPath)
  - [Poco](http://pocoproject.org/docs/Poco.Util.Application.html)

There are some paths to resource files that, depending on exact use case, may require
hard-coding or use of standard environment variables. On UNIX these are typically the
directories used for/by system programs, or for temporary usage.

- `/etc`
- `/var`
- `/tmp` or `TMPDIR`


