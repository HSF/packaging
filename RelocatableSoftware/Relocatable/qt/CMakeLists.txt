# - Demo Qt5's builtin self-location

# - Only need core lib
find_package(Qt5Core)

if(NOT Qt5Core_FOUND)
  message(STATUS "Qt5Core not found, disabling build of hsf-reloc-qt")
  return()
endif()

# - Build and link
add_executable(hsf-reloc-qt hsf-reloc-qt.cpp)
target_link_libraries(hsf-reloc-qt Qt5::Core)

