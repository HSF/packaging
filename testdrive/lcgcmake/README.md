# Test Driving the LCGCMake Package Manager

This document will walk you through preparing and using the [LCGCMake](https://gitlab.cern.ch/sft/lcgcmake)
package manager to install a basic software stack for HEP.

LCGCMake is the EP-SFT infrastructure to build the software stack for the LHC experiments
containing both external software dependencies and projects developed within the same group.
The tool is based on the [`ExternalProject`](http://www.kitware.com/media/html/BuildingExternalProjectsWithCMake2.8.html) module
of [CMake](https://cmake.org/).


## Base Operating System Install

Test driving LCGCMake requires either a CentOS6/7, Ubuntu 16.04LTS, or macOS High Sierra system. For macOS, only the base system
plus Xcode 9 from the App Store is required. Additional platform-specific requirements are specified on the official [documentation](https://gitlab.cern.ch/sft/lcgcmake#pre-requisites).
For convenience and reproducibility, Docker images are available for Linux, and can be obtained and run as follows:

```
# To pull it from dockerhub
docker pull hepsoftwarefoundation/c7-lcgcmake:latest

# ... or to directly run it (with implicit download if needed)
docker run -it hepsoftwarefoundation/c7-lcgcmake:latest bash
```

**Not yet uploaded**, meanwhile:

```
# To pull it from dockerhub
docker pull javiercvilla/c7-lcgcmake:latest

# ... or to directly run it (with implicit download if needed)
docker run -it javiervilla/c7-lcgcmake:latest bash
```

Optionally, you may use an existing Linux installation, but you may encounter errors in subsequent steps if it is missing
(or has incompatible) packages, or your environment has custom settings.

## Installing LCGCMake

1. **Install lcgcmake** by  just cloning the lcgcmake package from CERN GitLab and ensure that the PATH environment variable contains the `bin: directory from the just cloned repository.

  ```
  git clone https://gitlab.cern.ch/sft/lcgcmake.git
  export PATH=$PWD/lcgcmake/bin:$PATH
  ```

2. **Configure the software stack** by selecting the compiler and version  of the stack to be used

  ```
  lcgcmake configure --no-binary --version=latest [--prefix=...]
  ```
  - You can see the available compilers with the command `lcgcmake show compilers`
  - Similarly, you can see the available LCG stack versions with the command `lcgcmake show versions`
  - Once you have configured you can inspect the configuration with the command  `lcgcmake show configuration`


3. **Installation** of the required packages

  ```
  lcgcmake install <list of package names>
  ```
  - You can see the list of packages (targets) with `lcgcmake show targets`


4. **Setup environment and run** on a new shell with

  ```
  lcgcmake run
  ```


Previous steps will configure the whole LCGCMake project using the package versions specified in `lcgcmake/cmake/toolchain/heptools-latest.cmake`, which looks like this:

```
# Application Area Projects
if(NOT ${LCG_OS} STREQUAL mac)
  LCG_AA_project(COOL  3_2_0)
  LCG_AA_project(CORAL 3_2_0)
endif()
LCG_AA_project(RELAX root6)
LCG_AA_project(ROOT  6.14.00)
LCG_AA_project(HepMC 2.06.09)
LCG_AA_project(Geant4 10.04.p01)
LCG_AA_project(DD4hep 01-05)

# Externals
LCG_external_package(lcgenv            1.3.6                                  )
LCG_external_package(hepmc3            3.0.0                                  )
LCG_external_package(4suite            1.0.2p1                                )
LCG_external_package(absl_py           0.2.0                                  )
LCG_external_package(AIDA              3.2.1                                  )

```

The output of the former command should be similar to this:

```
-- The C compiler identification is GNU 4.8.5
-- The CXX compiler identification is GNU 4.8.5
-- The Fortran compiler identification is GNU 4.8.5
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features

[...]

-- Common compiler flags:
--   C :  -O2 -DNDEBUG
--   CXX : -std=c++11 -O2 -DNDEBUG
--   Fortran :  -O2 -DNDEBUG -O3
-- PDFsets to download                    : ct10 MSTW2008lo68cl cteq6ll cteq6l
-- Wrote package dependency information to /build/lcgcmake-build/dependencies.dot, /build/lcgcmake-build/dependencies.json and /build/lcgcmake-build/LCG_hsf_x86_64-centos7-gcc48-opt.txt.
-- Configuring done
-- Generating done
-- Build files have been written to: /build/lcgcmake-build
```

As you can see, since we have not configured any specific compiler, LCGCMake uses the default one provided by
the system. Other compilers can also be used by setting up the following environment variables:

- `PATH`, including the `bin` directory of the external compiler
- `LD_LIBRARY_PATH`. including the `lib64` directory

and overriding `FC`, `CC` and `CXX`, for example:

```
export FC=`which gfortran`
export CXX=`which g++`
export CC=`which gcc`
```

If you are running a docker container with the `c7-lcgcmake` image, a more recent gcc compiler is already
installed, to set it up just run the following command:

```
scl enable devtoolset-6 bash
```

This will run a different shell where `gcc-6.3.1` is set as the main compiler, so LCGCMake will use it
by default.

Additionally, `lcgcmake` can be also configured to use one of the preinstalled compilers in EOS (**we currently
recommend this way**), by adding the `--compiler` option at configuration time:

```
lcgcmake configure --compiler=gcc62binutils --version=latest [--prefix=...]
```

Once the project has been configured, packages defined in `lcgcmake/cmake/toolchain/heptools-latest.cmake` can be
built and installed using:

```
lcgcmake install <list of package names>
```

The whole list of available packages can be shown using:

```
lcgcmake show targets
```

For example, we can check our installation installing `zlib`. it should look like this:

```
$ lcgcmake install zlib
Scanning dependencies of target zlib-1.2.11
[  0%] Creating directories for 'zlib-1.2.11'
[  0%] Performing download step (download, verify and extract) for 'zlib-1.2.11'
-- downloading...
     src='http://lcgpackages.web.cern.ch/lcgpackages/tarFiles/sources/zlib-1.2.11.tar.gz'
     dst='/build/lcgcmake-build/externals/zlib-1.2.11/src/zlib-1.2.11.tar.gz'
     timeout='none'
-- downloading... done
-- verifying file...
     file='/build/lcgcmake-build/externals/zlib-1.2.11/src/zlib-1.2.11.tar.gz'
-- verifying file... warning: did not verify file - no URL_HASH specified?
-- extracting...
     src='/build/lcgcmake-build/externals/zlib-1.2.11/src/zlib-1.2.11.tar.gz'
     dst='/build/lcgcmake-build/externals/zlib-1.2.11/src/zlib/1.2.11'
-- extracting... [tar xfz]
-- extracting... [analysis]
-- extracting... [rename]
-- extracting... [clean up]
-- extracting... done
[  0%] No patch step for 'zlib-1.2.11'
[  0%] No update step for 'zlib-1.2.11'
[  0%] Installing sources for 'zlib-1.2.11'
[  0%] Performing configure step for 'zlib-1.2.11'
-- zlib-1.2.11 configure command succeeded.  See also /build/lcgcmake-build/externals/zlib-1.2.11/src/zlib-1.2.11-stamp/zlib-1.2.11-configure.log

[  0%] Performing build step for 'zlib-1.2.11'
-- zlib-1.2.11 build command succeeded.  See also /build/lcgcmake-build/externals/zlib-1.2.11/src/zlib-1.2.11-stamp/zlib-1.2.11-build.log

[ 50%] Performing install step for 'zlib-1.2.11'
-- zlib-1.2.11 install command succeeded.  See also /build/lcgcmake-build/externals/zlib-1.2.11/src/zlib-1.2.11-stamp/zlib-1.2.11-install.log

[ 50%] Installing log and version files for 'zlib-1.2.11'
[ 50%] Removing rpath from 'zlib-1.2.11'
[ 50%] Installing environment for zlib-1.2.11
[100%] Prepare post-install for zlib-1.2.11
[100%] Completed 'zlib-1.2.11'
[100%] Built target zlib-1.2.11
Scanning dependencies of target zlib
[100%] Built target zlib
```

As a result, `zlib` gets installed in the directory specify by the cmake options `DCMAKE_INSTALL_PREFIX`, which by default is `/opt/lcg`:

```
$ ls /opt/lcg/zlib/1.2.11/x86_64-centos7-gcc48-opt/
gen-post-install.log  include  lib  logs  share  version.txt  zlib-env.sh
```


## Installing the HEP Test Stack
The HSF Test Stack packages are as follows:

- **Toolchain**
  - GCC 6.4
    - With c, c++, fortran languages
  - Python 2.7.14
- **Core HEP Stack**
  - Boost 1.65
  - ROOT 6.12.06
    - Including PyROOT, MathMore
  - GSL 2.4
  - Qt5 5.10 (`qtbase` only)
  - Xerces-C 3.1.4
  - CLHEP (_Version to be compatible with Geant4_)
  - Geant4 10.3


To build all packages defined in the test stack, use the following custom target:

```
lcgcmake install HSF-testdrive
```

<!-- this will trigger the installation of all packages defined in `lcgcmake/cmake/toolchain/heptools-hsf.cmake`.
This file currently contains the packages above-mentioned plus all their dependencies. -->

For each package, the source tarfile will be downloaded from a private repo in EOS. This could be modified by
any other source, like the original webpage or its github repo, on the recipe of the package. These recipes
are splitted in different `CMakeLists.txt`:

- Project packages (ROOT, Geant4, HepMC): `lcgcmake/project/CMakeLists.txt`
- Project packages (MonteCarlo generator packages): `lcgcmake/generators/CMakeLists.txt`
- Project packages (rest of the packages): `lcgcmake/externals/CMakeLists.txt`

Optionally, binary installation can be enabled at configuration time removing the `--no-binary` option, since it is enabled by default:

```
lcgcmake configure --version=latest
```

Therefore, `lcgcmake` will first look at the [binary repository](http://lcgpackages.web.cern.ch/lcgpackages/tarFiles/releases/), if a package with the same specification (package + version + compiler + hash) was already installed and uploaded to the binary repository then it will be downloaded and installed from a tarball.

<!-- _**AUTHORS:**_ _Show any other features of the tool you think are useful here, e.g. build using different C++ Standards,
optional components of packages, different package versions_ -->

# Using the HEP Test Stack
To use a freshly installed test stack, it is quite convenient to build a `view`, `lcgcmake run` will create such view and start a new bash session with the environment ready to be used.

<!-- _**AUTHORS:**_ _Document the steps needed to setup a runtime environment for using
the stack listed above, including optional parts if the tools allows this_ -->

# Adding a New Package to the Stack

To add a new package to the stack, first you will need to add new package and its version to the list of packages in
the heptool file (`lcgcmake/heptools-latest.cmake` in our case) and steps to configure, build and install the package (as
well as any other required step) to the correspondant `CMakeLists.txt` file. For example, if we wanted to add `GSL-2.4` to our
stack we would add the following code:

```
// In heptools-XX.cmake ----------------------------------------------
LCG_external_package(clang  3.9.0)

//In externals/CMakeLists.txt-----------------------------------------

#----clang------------------------------------------------------------------------------
LCGPackage_Add(
  clang
  URL ${GenURL}/llvm-${clang_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DLLVM_TARGETS_TO_BUILD=host
             -DLLVM_ENABLE_ASSERTIONS=ON
             -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DLLVM_INCLUDE_TESTS=OFF
             -DLLVM_INCLUDE_EXAMPLES=OFF
  BUILD_COMMAND ${MAKE} clang
  INSTALL_COMMAND ${MAKE} install
  DEPENDS Python zlib
)
```

<!-- _**AUTHORS:**_ _Document the steps needed to create a package for a simple C/C++
library or application (your choice) and walkthrough the steps to build and install it. Reuse/link to the tool's
own documentation on this if you think it's sufficient_ -->

**Please refer to the [official documentation](https://gitlab.cern.ch/sft/lcgcmake/blob/master/README.md) for further information.**
