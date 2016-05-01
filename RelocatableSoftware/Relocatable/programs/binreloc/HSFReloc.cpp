#include "HSFReloc.h"

#include "hsf_binreloc.h"
#include <cstdlib>

namespace {
//! Initialize binreloc if needed
int initBinreloc() {
  int errorCode {0};
  static bool isInit {false};
  if (!isInit) {
    BrInitError err;
    errorCode = br_init(&err);
  }
  return errorCode;
}
}

namespace HSFReloc {
std::string getApplicationDir() {
  initBinreloc();
  char* myExeDir = br_find_exe_dir("");
  std::string exeDir = myExeDir;
  free(myExeDir);
  return exeDir;
}
} // namespace HSFReloc
