/**
  \file hsf-reloc-binreloc.cpp
  \brief Relocatable binreloc application
*/

#include <iostream>

#include "HSFReloc.h"

int main(int argc, char *argv[]) {
  auto appDir = HSFReloc::getApplicationDir();
  std::cout << appDir << "\n";
  return 0;
}
