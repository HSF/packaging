Notes on Tools/Techniques for Relocatable Packages
==================================================
This expands on notes already made in [the notes on packaging](dbm_Packaging_notes.md) related to *Relocatable Packages*. Though not an absolute
requirement for packaging, making a project relocatable helps with the
creation and installation of binary packages.

- **Project**: A software project such as ROOT or Geant4, a thing to be
built and packaged.
- **Installation Prefix**: Root directory under which all build products of
the **Project** are installed.
  - Usually set at the configuration step (e.g. `--prefix` in autotools
    or `-DCMAKE_INSTALL_PREFIX` in cmake)
- **Package Manager**: The tool used to build/install/update 1-N **Packages**
- **Source Package**: A script that describes how to configure, build, install and create a **Binary Package** for a **Project**.
- **Binary Package**: A single file containing the build products (programs,
libraries, headers, resources) of a **Project**.

The primary issue is that packages, source or binary, should be
installable without root or sudo privileges. This means that no fixed
installation prefix can be assumed, yet this may be required by a binary
package.


What is Relocatability?
=======================
**Relocatable** means that a package can be moved lock stock from its initial
installation location to anywhere else on the filesystem and still run
*without* user intervention. [OS X Application and Framework Bundles/Packages](https://developer.apple.com/library/mac/documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i)
are the classic exemplar of this for programs and libraries respectively, but
the same techniques can be applied across all platforms (the term
'Portable Binary' is often used on Linux). Relocatability is
helpful for packaging as it means that binary packages are easy to implement
without requiring a fixed installation root. It also helps to create a
**Single Rooted** installation structure whilst maintaining correct linking.

It should be noted that whilst environment variables are often used to provide
relocatability, this generally requires reconfiguration by the user and
is thus very fragile to environment misconfiguration. Better tools are
available for implementing relocatability, including

- Relative RPATHs, both on [OS X](http://www.kitware.com/blog/home/post/510) and [Linux](http://linux.die.net/man/8/ld.so)
- Application/Library self-location
  - [binreloc](https://github.com/drbenmorgan/Resourceful) at low level
  - Application objects in frameworks such as [Qt](http://doc.qt.io/qt-5/qcoreapplication.html#applicationDirPath) and [Poco](http://pocoproject.org/docs/Poco.Util.Application.html)

