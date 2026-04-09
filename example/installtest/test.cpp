// testinstall/test.cpp                                               -*-C++-*-
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include <name.hpp>
#include <iostream>

int main() {
  std::cout << "name: |" << example::name() << '|' << '\n';
  return 0;
}
