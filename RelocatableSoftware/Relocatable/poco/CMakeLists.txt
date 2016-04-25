# - Demo Poco's builtin self-location

# - Only need Util component for Application class
find_package(Poco COMPONENTS Util)

if(NOT Poco_FOUND)
  message(STATUS "Poco not found, disabling build of hsf-reloc-poco")
  return()
endif()

add_executable(hsf-reloc-poco hsf-reloc-poco.cpp)
target_link_libraries(hsf-reloc-poco Poco::Util)

