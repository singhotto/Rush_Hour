#ifndef RESOLVER__HH
#define RESOLVER__HH

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <algorithm>
#include <stdexcept>

class Resolver
{
private:
    int models, calls;
    float solving, first_model, unsat, cpu_time; 
    int cars, moves, occupied_cell, three_cell_cars, two_cell_cars;

    Resolver() = default;

    Resolver(const Resolver&) = delete;
    Resolver& operator=(const Resolver&) = delete;

    std::vector<std::map<int, std::map<std::string, std::vector<std::string>>>> all_answers;

    ~Resolver() = default;

    void saveTime(std::string& time);
public:
    static Resolver& getInstance();

    void resolve(const std::string& input, const std::string& logic, int n = 10);

    void getInfo(int &models, int &calls, float &solving, float &first_model, float &unsat, float &cpu_time, int& cars, int& three_cell_cars, int& two_cell_cars, int& moves, int& occupied_cell);

    void save(const std::string& output);
};

#endif