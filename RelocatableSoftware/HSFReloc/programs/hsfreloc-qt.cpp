/**
  \file hsf-reloc-qt.cpp
  \brief Relocatable Qt5 core application
*/

#include <iostream>

#include <QCoreApplication>

int main(int argc, char *argv[]) {
  QCoreApplication app(argc, argv);
  auto appDir = QCoreApplication::applicationDirPath();
  std::cout << appDir.toStdString() << "\n";

  return 0;
}
