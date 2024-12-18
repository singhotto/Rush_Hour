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
    Resolver() = default;

    Resolver(const Resolver&) = delete;
    Resolver& operator=(const Resolver&) = delete;

    std::vector<std::map<int, std::map<std::string, std::vector<std::string>>>> all_answers;

    ~Resolver() = default;
public:
    static Resolver& getInstance();

    void resolve(const std::string& input, const std::string& logic, int n = 10);

    void save(const std::string& output);
};

#endif