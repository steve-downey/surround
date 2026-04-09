// hello.cpp -*-C++-*-

#include <name.hpp>

#include <print>

std::string_view name() {
    static std::string my_name{"Steve"};
    return my_name;
}

int main() { std::println("Hello, {}!", name()); }
