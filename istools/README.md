# Instruction Set Tools

This project was inspired by discussion in [Packaging WG Meeting](https://indico.cern.ch/event/719557/).
It is intended as a collation of information and example code for
building and packaging code that uses specific instruction sets but
may run on (older) systems that do not support these on their CPUs.
Whilst this can, as discussed in [the presentation](https://indico.cern.ch/event/719557/contributions/2965980/attachments/1642767/2624258/HSF-Packaging-20180502.pdf), be handled by the package/configuration manager,
there may also be places where HEP software itself can be written
to handle this automatically or selectively.

This doesn't handle the case of things like auto-vectorization, or
third-party packages that set handle instructions sets in their
own way. We also look at ways to discover available instruction sets
at runtime to construct the platform tags as [described on slide 6](https://indico.cern.ch/event/719557/contributions/2965980/attachments/1642767/2624258/HSF-Packaging-20180502.pdf).

# Quickstart
The following software is needed to build and run the examples
in this project:

- Linux or macOS system (Windows, other POSIX platforms TBD)
- C/C++ compiler with C++14 support
- Bourne Shell
- CMake 3.9 or newer
- Make or Ninja buildtools

To build and test the programs, create a build directory,
run `cmake`, then `make`:

```
$ mkdir build
$ cd build
$ cmake ..
$ make
$ ./ist-detect
$ ./ist-detect-cpp
```

See the following sections for details on each of the available
programs and examples.

# Instruction Set Detection
We can determine the capabilities of the running CPU(s) in many ways.

## System/Shell Commands
At the basic system programming level, we can can use the `/proc/cpuinfo`
file (Linux) or `sysctl` program (macOS). The simple shell script
`ist-detect.sh` demonstrates a basic Bourne-shell script to query these and
output a list of capabilities. It may be run from the build directory directly as:

```console
$ ./ist-detect --usage
Usage: ist-detect [OPTION]

Supported values for OPTION are:

  --all-capabilities     print all CPU capabilities of this host
  --simd-capabilities    print all SIMD capabilities of this host
  --help                 display this help and exit

$
```

Here, the `--all-capabilities` argument will display the list of all CPU
capabilities of the current host. The `--simd-capabilties` argument will display
just the SIMD flags. Note that

- On macOS, the output of `sysctl` is uppercase, so we lower the output for
  compatibility with Linux.
- Given capabilities are not always listed identically, e.g. SSE4.X availablity
  on Linux is indicated by the flag `sse4_1`, whereas macOS lists it as `sse4.1`
  (after lowercasing). A standard format is on the TODO list.


## C/C++ Interfaces
Using C/C++, direct Assembly or suitable wrappers such as `__cpuid` can
be used. The simple `ist-detect.cpp` program uses the `instrset` interfaces
from the [Vector Class Library](http://www.agner.org/optimize/vectorclass.pdf)
to print out an integer representing the newest instruction set supported by
the host CPU. As of Vector Class v1.28, these are:

- `0           = 80386 instruction set`
- `1  or above = SSE (XMM) supported by CPU (not testing for O.S. support)`
- `2  or above = SSE2`
- `3  or above = SSE3`
- `4  or above = Supplementary SSE3 (SSSE3)`
- `5  or above = SSE4.1`
- `6  or above = SSE4.2`
- `7  or above = AVX supported by CPU and operating system`
- `8  or above = AVX2`
- `9  or above = AVX512F`
- `10 or above = AVX512VL`
- `11 or above = AVX512BW, AVX512DQ`

One can expect this list to extend as time moves on, though this project will
likely not keep in lock step as it is a pure demo.

The `ist-detect.cpp` file is compiled by the build to the `ist-detect-cpp` program.
This may be executed directly from the build directory, where it will
output an ordered list of oldest to newest SIMD instructions supported by the
host. For example on a macOS host with Xeon CPU:

```
$ ./ist-detect-cpp
Most modern SIMD available: avx
Supported SIMD: 80386 sse sse2 sse3 ssse3 sse4_1 sse4_2 avx
```

# Binary Packaging/Deployment with SIMD/Intrinsics
If a (binary) program or library uses SIMD/intrinsic instructions, it will only be runnable
on other systems where the host CPU provides the needed instructions (even if the
OS/toolchain are otherwise identical). When creating binary packages for install/use (e.g.
as Spack/Nix packages, or published on CVMFS servers), care must be taken to ensure
compatible binary(ies) is(are) selected or otherwise available at runtime. For example,
if we try and run code with AVX2 instructions on a host whose CPU only supports SSE4.2,
we will get runtime errors, usually of the "Illegal instruction" form. There are several
possible ways to ensure compatibility via compilation and/or configuration management.

The compiler/toolchain will use (_sensible, portable?_) platform/configuration dependent
defaults for instruction sets, but this can be controlled via flags such as `-m` and `-march`
(GCC/Clang). The effect of the `-march` and `-m<INSTRUCTIONSET>` flags on availability of SIMD instruction
preprocessor macros (and consequently intrinsics) is shown by the tiny demo program `ist-simd-macros.cpp`.
This is compiled into separate executables with differing flags as follows:

- `ist-simd-default` : `$CXX`-std=c++14`
- `ist-simd-native`  : `$CXX -std=c++14 -march=native`
- `ist-simd-core2`   : `$CXX -std=c++14 -march=core2`
- `ist-simd-sse2`    : `$CXX -std=c++14 -march=sse2`
- `ist-simd-avx`     : `$CXX -std=c++14 -march=avx`
- `ist-simd-avx2`    : `$CXX -std=c++14 -march=avx2`
- `ist-simd-avx512`  : `$CXX -std=c++14 -march=avx512` (_may be avx512f_)

You can compare the output of these programs with that from the `ist-detect` or `ist-detect-cpp`
programs which show the true capabilities of your host's CPU. In some cases you will note that
there are instruction sets that could be compiled but are not supported by your CPU (and yes, you can compile
code on your local machine that won't run on it)!

By using the above flags, we can configure the toolchain such that all of our
packages are compiled with a "minimum" SIMD instruction set. If this is chosen
in line with the oldest CPU(s) we expect to support, we can distribute these binaries
with a reasonable guarantee they will run on the vast majority of systems.
This is the approach taken in Home/Linuxbrew, where binary packages are compiled
using `-march=core2` to provide a very high degree of portability. Of course, this
costs some performance as we may end up running SSE2 code on a machine that could support
AVX512. To overcome this, and as recommended in the [HSF Platform Naming Convention](https://github.com/HSF/documents/blob/master/HSF-TN/2018-01/HSF-TN-2018-01.pdf), we can build against a given instruction
set and add this as part of the platform name. This partitions stacks into capability slices,
e.g.

```
/cvmfs
 +- stack_root/
    +- x86_64+ssse3-centos7-gcc7-opt/
    |  + ... binaries compatible with any x86_64 CPU supporting SSSE3 or newer
    +- x86_64+avx512-centos7-gcc7-opt/
       + ... binaries compativle with any x86_64 CPU supporting AVX512 or newer
```

This places responsibility on the configuration manager (modules, views, scripts) to
determine a stack compatible with the host system. However, the instruction set detection
tools from earlier provide a example implementation of detecting this.

TODO:
- [ ] Demonstrate basic example of runtime dispatch methods/fat binaries
- [ ] Document when, and when not, to use this, plus performance measurements/comparisons.

# Useful Links
## General
- [Optimizing software in C++, Section 13](http://www.agner.org/optimize/optimizing_cpp.pdf)
- [IsoC++ Discussion Thread](https://groups.google.com/a/isocpp.org/forum/#!msg/std-proposals/SwDyE6KH87Y/jmj8bbKucIwJ)
- [Intel MKL Automatic and Selective Dispatch](https://software.intel.com/en-us/mkl-linux-developer-guide-instruction-set-specific-dispatching-on-intel-architectures)
- [OpenCV Build/CPU Optimizations](https://github.com/opencv/opencv/wiki/CPU-optimizations-build-options)


## Compiler specific methods

- [GCC Function Multiversioning](https://gcc.gnu.org/onlinedocs/gcc/Function-Multiversioning.html)
- [Intel `cpu_dispatch`](https://software.intel.com/en-us/articles/how-to-manually-target-2nd-generation-intel-core-processors-with-support-for-intel-avx)

