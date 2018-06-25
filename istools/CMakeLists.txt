cmake_minimum_required(VERSION 3.9)
project(istools VERSION 0.0.1 LANGUAGES CXX)

include(CheckCXXCompilerFlag)

set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 14)

# Create static lib for VCL as we'll use it in a couple
# of places
add_library(vcl STATIC vcl/instrset.h vcl/instrset_detect.cpp)
target_compile_definitions(vcl PUBLIC VCL_NAMESPACE=ist)

#-----------------------------------------------------------------------
# - SIMD detection examples
#
# Compile everything into one exe for now
add_executable(ist-detect-cpp ist-detect.cpp)
target_link_libraries(ist-detect-cpp PRIVATE vcl)

# Copy script into build dir, only for clarity
configure_file(ist-detect.sh ist-detect COPYONLY)

#-----------------------------------------------------------------------
# - SIMD macros for various "-m" or "-march" options
#   "march" seems most useful to define a minimum level of support
#   as it refers to a generation of CPUs, albeit vendor dependent
#   Whilst "-m<set>" also sets a default, it's overidden if the
#   host/target system is backward compatible. E.g. on a system
#   supporting sse4_1, using just "-msse3" would still result in
#   __SSE4_1__ begin defined.
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|(Apple)Clang")
  # Default, which have nothing on the command line
  add_executable(ist-simd-default ist-simd-macros.cpp)
  # Should always have march=core2/native/sse2
  add_executable(ist-simd-native ist-simd-macros.cpp)
  target_compile_options(ist-simd-native PRIVATE "-march=native")
  add_executable(ist-simd-core2 ist-simd-macros.cpp)
  target_compile_options(ist-simd-core2 PRIVATE "-march=core2")
  add_executable(ist-simd-sse2 ist-simd-macros.cpp)
  target_compile_options(ist-simd-sse2 PRIVATE "-msse2")

  # AVX/2/512
  check_cxx_compiler_flag("-mavx" HAVE_MAVX)
  if(HAVE_MAVX)
    add_executable(ist-simd-avx ist-simd-macros.cpp)
    target_compile_options(ist-simd-avx PRIVATE "-mavx")
  endif()

  check_cxx_compiler_flag("-mavx2" HAVE_MAVX2)
  if(HAVE_MAVX)
    add_executable(ist-simd-avx2 ist-simd-macros.cpp)
    target_compile_options(ist-simd-avx2 PRIVATE "-mavx")
  endif()

  check_cxx_compiler_flag("-mavx512" HAVE_MAVX512)
  check_cxx_compiler_flag("-mavx512f" HAVE_MAVX512F)
  if(HAVE_MAVX512 OR HAVE_MAVX512F)
    add_executable(ist-simd-avx512 ist-simd-macros.cpp)
    target_compile_options(ist-simd-avx512 PRIVATE
      "-mavx512$<$<BOOL:HAVE_MAVX512F>:f>"
      )
  endif()
endif()

