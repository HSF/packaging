/**
  \file slpackage.cpp
  \brief Relocatable binreloc application
*/

#include <iostream>
#include <fstream>
#include <streambuf>

#include "SLPApplicationPaths.h"

int main(int argc, char *argv[]) {
  auto appDir = SLP::getApplicationDir();
  std::cout << "[application in]: " << appDir << "\n";

  auto resPath = SLP::getResourceDir() + "/" + "resource.txt";

  std::ifstream resStream {resPath};
  if (resStream.good()) {
    std::string resContent {std::istreambuf_iterator<char>(resStream),
                            std::istreambuf_iterator<char>()};
    std::cout << "[resource]: '" << resContent << "'\n";
  } else {
    std::cerr << "[error]: could not open resource \"" << resPath << "\"\n";
  }
  return 0;
}
