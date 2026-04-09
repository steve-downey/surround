// example/name.test.cpp                      -*-C++-*-
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#include <name.hpp>

#include <name.hpp> // test 2nd include OK

#include <gtest/gtest.h>

TEST(Test, Fail) { SUCCEED(); }

TEST(TestName, Steve) { ASSERT_EQ(example::name(), "Steve"); }
