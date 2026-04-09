#include <name.hpp>

std::string_view example::name() {
    static std::string my_name{"Steve"};
    return my_name;
}
