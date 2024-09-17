#include <iostream>
#include <curl/curl.h>
#include "./include/test.hpp"
int main() {
    std::cout << generateGreeting("world") << std::endl;
    return 0;
}