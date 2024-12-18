#include <iostream>
#include <string>
#include "utils/ImgGenerator.hh"

int main(){
    std::string init = "../data/input1.asp";
    std::string res = "../data/data_1.txt";
    ImgGenerator g(init, res);
    g.generate();
    return 0;
}