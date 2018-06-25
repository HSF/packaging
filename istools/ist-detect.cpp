#include <iostream>
#include <vector>
#include <string>
#include "vcl/instrset.h"

namespace ist {
using SIMDCapabilities = std::vector<std::string>;

//! Known SIMD instruction sets in VCL 1.28
const SIMDCapabilities KnownSIMDCapabilities
{
  "80386",
  "sse",
  "sse2",
  "sse3",
  "ssse3",
  "sse4_1",
  "sse4_2",
  "avx",
  "avx2",
  "avx512f",
  "avx512vl",
  "avx512bw"
};

//! return vector of SIMD capabilities supported on this host
SIMDCapabilities get_simd_capabilities()
{
  int i{ist::instrset_detect()};
  return SIMDCapabilities{&KnownSIMDCapabilities[0], &KnownSIMDCapabilities[i+1]};
}

//! return name of SIMD set identified by integer
std::string get_simd_name(const int id) {
  return KnownSIMDCapabilities.at(id);
}

} // namespace ist


int main()
{
  std::cout << "Most modern SIMD available: "
            << ist::get_simd_name(ist::instrset_detect())
            << std::endl;

  std::cout << "Supported SIMD: ";
  for(auto const& i : ist::get_simd_capabilities()) {
    std::cout << i << " ";
  }
  std::cout << std::endl;

  return 0;
}

