#!/usr/bin/env python3

cpp_code = """
#include <iostream>

int main() {
    std::cout << "Hello, World!\nThis is a stub for a file that generates the code of the moment_arm, probably from the ipynb from Stanev, to be added here!" << std::endl;
    return 0;
}
"""

with open("generated_moment_arm.cpp", "w") as file:
    file.write(cpp_code)
