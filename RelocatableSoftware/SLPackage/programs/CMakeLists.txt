# - Build application/library using binreloc for self-location


# - Configure binreloc
# Just mangles symbols which is not strictly neccessary for programs.
# However, when we use it in libraries, we *might* get symbol clashes if
# we link together several libraries, each with their own binreloc code.
#string(RANDOM LENGTH 16 MANGLE_BINRELOC)
#set(MANGLE_BINRELOC "hsf_reloc_binreloc${MANGLE_BINRELOC}")
#configure_file(binreloc/hsf_binreloc.h.in hsf_binreloc.h @ONLY)
include(binreloc/GenerateBinreloc.cmake)

# - Configure "front end" to binreloc, adding known *relative path*
# from exe dir to resource dir
file(RELATIVE_PATH SLP_BINDIR_TO_RESOURCEDIR
  "${CMAKE_INSTALL_FULL_BINDIR}"
  "${CMAKE_INSTALL_FULL_DATADIR}/${PROJECT_NAME}/resources"
  )
configure_file(SLPApplicationPaths.cpp.in SLPApplicationPaths.cpp @ONLY)

add_executable(slp-binreloc
  SLPApplicationPaths.h
  ${CMAKE_CURRENT_BINARY_DIR}/SLPApplicationPaths.cpp
  slp-binreloc.cpp
  )
target_include_directories(slp-binreloc PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  )

# Generate and link binreloc code for this exe.
# It's always a private link because binreloc is only
# ever an implementation detail of clients.
generate_binreloc(SLPackage)
target_link_libraries(slp-binreloc PRIVATE SLPackage_binreloc)

#-----------------------------------------------------------------------
# - Optional Poco demo for its builtin self location
# - Only need Util lib directly for Application base class
find_package(Poco QUIET COMPONENTS Util)

if(NOT Poco_FOUND)
  message(STATUS "Poco not found, disabling build of slp-poco")
else()
  add_executable(slp-poco slp-poco.cpp)
  target_link_libraries(slp-poco Poco::Util)
endif()

#-----------------------------------------------------------------------
# - Optional Qt5 demo for its builtin self-location
# - Only need core lib
find_package(Qt5Core QUIET)

if(NOT Qt5Core_FOUND)
  message(STATUS "Qt5Core not found, disabling build of slp-qt")
else()
  add_executable(slp-qt slp-qt.cpp)
  target_link_libraries(slp-qt Qt5::Core)
endif()

