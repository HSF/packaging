/**
  \file hsf-reloc-poco.cpp
  \brief Relocatable Poco core application

  Poco applications can be implemented as classes derived from the Application
  base class. A macro is provided to construct/use the class in the actual
  main() function.
*/

#include <Poco/Util/Application.h>

//! Concrete application class
class HSFReloc : public Poco::Util::Application {
  //! Implementation of main method
  int main(const std::vector<std::string>&) {
    auto hsfrelocDir = this->config().getString("application.dir");
    this->logger().information(hsfrelocDir);
    return 0;
  }
};

POCO_APP_MAIN(HSFReloc)

