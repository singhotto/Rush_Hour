#include <iostream>
#include <string>
#include "utils/ImgGenerator.hh"

int main(){
    std::string init = "../data/input3.asp";
    std::string res = "../data/data_3.txt";
    ImgGenerator g(init, res);
    g.generate();
    return 0;
}