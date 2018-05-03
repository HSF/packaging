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

# Useful Links
## General
- [Optimizing software in C++, Section 13](http://www.agner.org/optimize/optimizing_cpp.pdf)
- [IsoC++ Discussion Thread](https://groups.google.com/a/isocpp.org/forum/#!msg/std-proposals/SwDyE6KH87Y/jmj8bbKucIwJ)
- [Intel MKL Automatic and Selective Dispatch](https://software.intel.com/en-us/mkl-linux-developer-guide-instruction-set-specific-dispatching-on-intel-architectures)
- [OpenCV Build/CPU Optimizations](https://github.com/opencv/opencv/wiki/CPU-optimizations-build-options)


## Compiler specific methods

- [GCC Function Multiversioning](https://gcc.gnu.org/onlinedocs/gcc/Function-Multiversioning.html)
- [Intel `cpu_dispatch`](https://software.intel.com/en-us/articles/how-to-manually-target-2nd-generation-intel-core-processors-with-support-for-intel-avx)

