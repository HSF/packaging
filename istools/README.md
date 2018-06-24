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
output a list of capabilities. Note that:

- On macOS, the output of sysctl is uppercase, so we lower the output for
  compatibility with Linux.
- Given capabilities are not always listed identically, e.g. SSE4.X availablity
  on Linux is indicated by the flag `sse4_1`, whereas macOS lists it as `sse4.1`
  (after lowercasing).
- The list is all capabilities, so more than SIMD flags are listed.

## C/C++ Interfaces
Using C/C++, direct Assembly or suitable wrappers such as `__cpuid` can
be used. The simple `ist-detect.cpp` program uses the `instrset` interfaces
from the [Vector Class Library](http://www.agner.org/optimize/vectorclass.pdf)
to print out an integer representing the newest instruction set supported by
the host CPU. As of Vector Class v1.25, these are:

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

# Useful Links
## General
- [Optimizing software in C++, Section 13](http://www.agner.org/optimize/optimizing_cpp.pdf)
- [IsoC++ Discussion Thread](https://groups.google.com/a/isocpp.org/forum/#!msg/std-proposals/SwDyE6KH87Y/jmj8bbKucIwJ)
- [Intel MKL Automatic and Selective Dispatch](https://software.intel.com/en-us/mkl-linux-developer-guide-instruction-set-specific-dispatching-on-intel-architectures)
- [OpenCV Build/CPU Optimizations](https://github.com/opencv/opencv/wiki/CPU-optimizations-build-options)


## Compiler specific methods

- [GCC Function Multiversioning](https://gcc.gnu.org/onlinedocs/gcc/Function-Multiversioning.html)
- [Intel `cpu_dispatch`](https://software.intel.com/en-us/articles/how-to-manually-target-2nd-generation-intel-core-processors-with-support-for-intel-avx)

