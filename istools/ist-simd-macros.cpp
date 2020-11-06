//! Compile this with different "-m" flags
//  to see effect of different flags on defined SIMD sets
#include <iostream>

int main()
{
#ifdef __SSE__
  std::cout << "__SSE__ defined\n";
#endif

#ifdef __SSE2__
  std::cout << "__SSE2__ defined\n";
#endif

#ifdef __SSE3__
  std::cout << "__SSE3__ defined\n";
#endif

#ifdef __SSSE3__
  std::cout << "__SSSE3__ defined\n";
#endif

#ifdef __SSE4_1__
  std::cout << "__SSE4_1__ defined\n";
#endif

#ifdef __SSE4_2__
  std::cout << "__SSE4_2__ defined\n";
#endif

#ifdef __AVX__
  std::cout << "__AVX__ defined\n";
#endif

#ifdef __AVX2__
  std::cout << "__AVX2__ defined\n";
#endif

#if defined(__AVX512__) || defined(__AVX512F__)
  std::cout << "__AVX512__ defined\n";
#endif

  return 0;
}
