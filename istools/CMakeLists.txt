cmake_minimum_required(VERSION 3.9)
project(istools VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 14)

# Create static lib for VCL as we'll use it in a couple
# of places
add_library(vcl STATIC vcl/instrset.h vcl/instrset_detect.cpp)
target_compile_definitions(vcl PUBLIC VCL_NAMESPACE=ist)

# Compile everything into one exe for now
add_executable(ist-detect-cpp ist-detect.cpp)
target_link_libraries(ist-detect-cpp PRIVATE vcl)

# Copy script into build dir, only for clarity
configure_file(ist-detect.sh ist-detect COPYONLY)

