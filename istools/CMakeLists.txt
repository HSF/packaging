cmake_minimum_required(VERSION 3.9)
project(istools VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 14)

# Compile everything into one exe for now
add_executable(ist-detect-cpp ist-detect.cpp
  vcl/instrset.h
  vcl/instrset_detect.cpp
  )
# Use VectorClassLibrary's configurable namespace
target_compile_definitions(ist-detect-cpp
  PRIVATE VCL_NAMESPACE=ist
  )

# Copy script into build dir, only for clarity
configure_file(ist-detect.sh ist-detect COPYONLY)
