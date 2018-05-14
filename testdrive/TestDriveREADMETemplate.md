# Test Driving the Foo Package Manager 

_**AUTHORS:**_ _Change "Foo" here and elsewhere in the template to the name of the package manager_

This document will walk you through preparing and using the Foo (_**AUTHORS:**_ _Provide a link to the tool's home page_)
package manager to install a basic software stack for HEP. 

Foo is ...

_**AUTHORS:**_ _Provide a brief description of Foo and what is good about it, defer to the tool's own docs if preferred!_



## Base Operating System Install

_**AUTHORS:**_ _Assume a base system of macOS High Sierra with Xcode 9, or a Docker Image based on centos:centos7 or 
ubuntu:xenial. In the Docker case, supply (a) Dockerfile(s) for each system, adding any additional system packages 
required, and (b) an `hsf` user with `sudo` privileges that the container will run as. There’s no requirement 
to build and host the images. Bonus points: Singularity! If macOS needs additional packages, document them below:_

Test driving Foo requires either a CentOS6/7, Ubuntu 16.04LTS, or macOS High Sierra system. For macOS, only the base system 
plus Xcode 9 from the App Store (_**AUTHORS:**_ _add any additional requirements here_) is required. For convenience and 
reproducibility, Docker images are available for Linux, and can be obtained and run as follows:

_**AUTHORS:**_ _Add Docker pull/build/run instructions here_

Optionally, you may use an existing Linux installation, but you may encounter errors in subsequent steps if it is missing 
(or has incompatible) packages, or your environment has custom settings.

## Installing Foo
To install Foo, ...

_**AUTHORS:**_ _Add instructions here. Aim should be to get Foo up and running in the most minimal way
possible. Include a set of test/sanity checks and install of a "hello world" package like `zlib` if the 
packages manager allows. In both cases, reuse/link to the tool's own documentation if you think it's clear enough_

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

To install this stack, ...

_**AUTHORS:**_ _Document the steps needed to install these packages from source, and separately from 
binary if the tool provides these_ 

Optionally, ...

_**AUTHORS:**_ _Show any other features of the tool you think are useful here, e.g. build using different C++ Standards,
optional components of packages, different package versions_

# Using the HEP Test Stack
To use the freshly installed test stack, ...

_**AUTHORS:**_ _Document the steps needed to setup a runtime environment for using
the stack listed above, including optional parts if the tools allows this_

# Adding a New Package to the Stack
To add a new package to the stack, ...

_**AUTHORS:**_ _Document the steps needed to create a package for a simple C/C++
library or application (your choice) and walkthrough the steps to build and install it. Reuse/link to the tool's
own documentation on this if you think it's sufficient_
