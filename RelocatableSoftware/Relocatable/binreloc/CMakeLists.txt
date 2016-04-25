# - Build application/library using binreloc for self-location

# - Configure binreloc
# Just mangles symbols which is not strictly neccessary for programs.
# However, when we use it in libraries, we *might* get symbol clashes if
# we link together several libraries, each with their own binreloc code.
string(RANDOM LENGTH 16 MANGLE_BINRELOC)
set(MANGLE_BINRELOC "hsf_reloc_binreloc${MANGLE_BINRELOC}")
configure_file(hsf_binreloc.h.in hsf_binreloc.h @ONLY)

add_executable(hsf-reloc-binreloc
  hsf_binreloc.h
  hsf_binreloc.c
  HSFReloc.h
  HSFReloc.cpp
  hsf-reloc-binreloc.cpp
  )
target_include_directories(hsf-reloc-binreloc PRIVATE
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
  )
target_compile_definitions(hsf-reloc-binreloc PRIVATE ENABLE_BINRELOC)

