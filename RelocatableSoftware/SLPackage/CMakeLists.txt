# - Build/Test Examples for Self-Locating Binaries
cmake_minimum_required(VERSION 3.3)
project(SLPackage VERSION 0.1.0)

# - Use standard install locations
# These are, by default, relative to CMAKE_PREFIX_PATH so permit relocatability
include(GNUInstallDirs)

# - Use install directories to configure output paths of build products
# We do this so we can reproduce the install layout in the build directory
# and hence relative paths between products(*)
# (*) resource files are slightly different
set(SLPackage_BUILDPRODUCT_DIRECTORY "${PROJECT_BINARY_DIR}/BuildProducts")
if(NOT CMAKE_CONFIGURATION_TYPES)
  # Single mode tools (make etc)
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${SLPackage_BUILDPRODUCT_DIRECTORY}/${CMAKE_INSTALL_LIBDIR}")
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${SLPackage_BUILDPRODUCT_DIRECTORY}/${CMAKE_INSTALL_LIBDIR}")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${SLPackage_BUILDPRODUCT_DIRECTORY}/${CMAKE_INSTALL_BINDIR}")
else()
  # Multimode tools (Xcode)
  foreach(_mode ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${_mode} _mode_uc)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${_mode_uc} "${SLPackage_BUILDPRODUCT_DIRECTORY}/${_mode}/${CMAKE_INSTALL_LIBDIR}")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${_mode_uc} "${SLPackage_BUILDPRODUCT_DIRECTORY}/${_mode}/${CMAKE_INSTALL_LIBDIR}")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${_mode_uc} "${SLPackage_BUILDPRODUCT_DIRECTORY}/${_mode}/${CMAKE_INSTALL_BINDIR}")
  endforeach()
endif()

# - Force C++11 without checking available features
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# - Build subdirs
add_subdirectory(programs)

# - copy/configure resources to build dir
file(COPY resources
  DESTINATION ${SLPackage_BUILDPRODUCT_DIRECTORY}/${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}
  )
