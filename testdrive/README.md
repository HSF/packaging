# Packaging Working Group - Test Drive Area

This directory holds documentation and files for test driving various package manager tools
to demonstrate the installation and use a [HEP test stack](#hep-test-stack) in order to
evaluate the various [identified use cases](https://docs.google.com/document/d/1h-r3XPIXXxmr5tThIh6gu6VcXXRhBXtUuOv14ju3oTI/).
We currently have test drives for:

- [nix](nix)
- [portage](portage)
- [spack](spack)

See the READMEs in each directories for more details on the tool and instructions for taking it for a test drive.
If you want to create a test drive for a new package manager, please see the information below.


## HEP Test Stack

From discussions in [HSF Packaging Meeting #14](https://indico.cern.ch/event/678307/), a minimal subset of packages
was identified to exercise the package managers with:

- **Toolchain**
  - GCC 6.4
    - With c, c++, fortran languages
  - Python 2.7.14
  - _Plus any packages required to build and run the above_
- **Core HEP Stack**
  - Boost 1.65
  - ROOT 6.12.06
    - Including PyROOT, MathMore
  - GSL 2.4
  - Qt5 5.10 (`qtbase` only)
  - Xerces-C 3.1.4
  - CLHEP (_Version to be compatible with Geant4_)
  - Geant4 10.3
  - _Plus any packages required to build and run the above_

## HEP Stack Test Drive Program

To enable to WG (and eventually the broader HEP community) to evaluate how well a given package manager solves the [identified use cases](https://docs.google.com/document/d/1h-r3XPIXXxmr5tThIh6gu6VcXXRhBXtUuOv14ju3oTI/) as well as general considerations such as portability and ease of use, a basic list of tasks is outlined to provide a template for "driving lessons" on:

- Installing the package manager
- Installing the first package
- Installing the HEP Test Stack
- Using installed packages
- Adding new packages
- Developing software against installed packages

To keep things simple some simplifying assumptions are made:

- [Docker](https://www.docker.com) images are used for testing Linux platforms.

  This is purely for consistency and reproducibility, and does not suggest that containers will be the only way to
  use a given package manager! It also helps to enumerate the OS packages that are always needed by the package manager.

- No use of [CVMFS](https://cernvm.cern.ch/portal/filesystem) is assumed yet.

  This is to ensure that test drivers get a feel for building from source,
  installing from binary, writing packages for their own software, and the balance between reuse of OS
  packages vs “compile the world”.

  It does not imply that CVMFS will not be used later, but users will have to go through the packaging steps to have
  something to deploy to CVMFS! Smaller experiments may also not have access to CVMFS.

- The test driver may have `sudo` access, but the steps requiring this should be minimized and ideally zero.

## Creating a new Test Drive Program

