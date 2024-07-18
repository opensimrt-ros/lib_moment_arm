#!/usr/bin/env python3
import argparse


cpp_code = """
#include <iostream>

int main() {
    std::cout << "Hello, World!\nThis is a stub for a file that generates the code of the moment_arm, probably from the ipynb from Stanev, to be added here!" << std::endl;
    return 0;
}
"""

parser = argparse.ArgumentParser(description='Process some subj.')
parser.add_argument('subject')
parser.add_argument('model')   




args = parser.parse_args()


print(args)

print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")
print("-----------------------------------------")

model = args.model
subject = args.subject

with open(f"{model}MomentArm_{subject}.cpp", "w") as file:
    file.write(cpp_code)
