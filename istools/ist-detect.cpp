#include <iostream>

#include "vcl/instrset.h"

int main()
{
  std::cout << "highest supported instruction set: "
            << ist::instrset_detect()
            << std::endl;
  return 0;
}

