#include "Resolver.hh"
#include <fstream>
#include <cerrno>
#include <cstring>
#include <regex>

void getCarsInfo(const std::string& filename, int& n_cars, int& occupied_cell, int& three_cell_cars, int& two_cell_cars) {
    std::ifstream file(filename);

    if (!file.is_open()) {
        throw std::runtime_error ("Error: Unable to open file " + filename + "\n");
    }

    std::string line;
    std::regex carRegex(R"(^car\((\d+),\s*(\d+),\s*([hv]),\s*\((\d+),\s*(\d+)\)\)\.)");
    
    std::smatch match;


    while (std::getline(file, line)) {
        if (std::regex_match(line, match, carRegex)) {
            ++n_cars;
            int car_size = std::stoi(match[2].str());
            occupied_cell+= car_size;
            if(2 == car_size){
                two_cell_cars++;
            }else{
                three_cell_cars++;
            }
        }
    }

    file.close();
}

// Function to trim whitespace from both ends of a string
std::string trim(const std::string &s)
{
    size_t start = s.find_first_not_of(" \t\r\n");
    size_t end = s.find_last_not_of(" \t\r\n");
    if (start == std::string::npos)
        return "";
    return s.substr(start, end - start + 1);
}

// Function to parse an atom and extract T and the atom string
bool parse_atom(const std::string &atom, int &T, std::string &predicate, std::string &full_atom)
{
    size_t first_paren = atom.find('(');
    size_t comma = atom.find(',', first_paren);
    if (first_paren == std::string::npos || comma == std::string::npos)
        return false;

    std::string T_str = atom.substr(first_paren + 1, comma - first_paren - 1);
    try
    {
        T = std::stoi(trim(T_str));
    }
    catch (...)
    {
        return false;
    }

    predicate = trim(atom.substr(0, first_paren)); // Extract the predicate name
    full_atom = trim(atom);                        // Store the full atom for later use
    return true;
}

Resolver &Resolver::getInstance()
{
    static Resolver instance; // Guaranteed to be destroyed, instantiated on first use
    return instance;
}

void Resolver::saveTime(std::string &t_time)
{
    // Regular expressions for each field
    std::regex models_regex(R"(^Models\s*:\s*(\d+))", std::regex::icase);
    std::regex calls_regex(R"(^Calls\s*:\s*(\d+))", std::regex::icase);
    std::regex time_details_regex(R"(\s*([\d.]+)s\b.*\b\bSolving:\s*([\d.]+)s\b.*\b1st Model:\s*([\d.]+)s\b.*\bUnsat:\s*([\d.]+)s\b)", std::regex::icase);
    std::regex cpu_time_regex(R"(^CPU Time\s*:\s*([\d.]+))", std::regex::icase);

    std::regex choices_regex(R"(^Choices\s*:\s*(\d+))", std::regex::icase);
    std::regex conflicts_regex(R"(^Conflicts\s*:\s*(\d+)\s*\(Analyzed:\s*(\d+)\))", std::regex::icase);
    std::regex restarts_regex(R"(^Restarts\s*:\s*(\d+)\s*\(Average:\s*([\d.]+)\s*Last:\s*([\d.]+)\))", std::regex::icase);
    std::regex constraints_regex(R"(^Constraints\s*:\s*(\d+)\s*\(Binary:\s*([\d.]+)%\s*Ternary:\s*([\d.]+)%\s*Other:\s*([\d.]+)%\))", std::regex::icase);

    // Process each line of the input
    std::istringstream ss(t_time);
    std::string line;

    while (std::getline(ss, line)) {
        std::smatch match;
        if (std::regex_search(line, match, models_regex)) {
            models = std::stoi(match[1].str());
        } else if (std::regex_search(line, match, calls_regex)) {
            calls = std::stoi(match[1].str());
        } else if (line.find("Time") != std::string::npos && std::regex_search(line, match, time_details_regex)) {
            time = std::stof(match[1].str());
            solving = std::stof(match[2].str());
            first_model = std::stof(match[3].str());
            unsat = std::stof(match[4].str());
        } else if (std::regex_search(line, match, cpu_time_regex)) {
            cpu_time = std::stof(match[1].str());
        } else if (std::regex_search(line, match, choices_regex)) {
            choices = std::stof(match[1].str());
        } else if (std::regex_search(line, match, conflicts_regex)) {
            conflicts = std::stof(match[1].str());
        } else if (std::regex_search(line, match, restarts_regex)) {
            restarts = std::stof(match[1].str());
        } else if (std::regex_search(line, match, constraints_regex)) {
            binary = std::stof(match[2].str());
            ternary = std::stof(match[3].str());
        }
    }
}

void Resolver::printStats()
{
    std::cout << "Models       : " << models << std::endl;
    std::cout << "Calls        : " << calls << std::endl;
    std::cout << "Time         : " << time << "s (Solving: " << solving << "s 1st Model: " << first_model 
              << "s Unsat: " << unsat << "s)" << std::endl;
    std::cout << "CPU Time     : " << cpu_time << "s" << std::endl;
    std::cout << "Choices      : " << choices << std::endl;
    std::cout << "Conflicts    : " << conflicts << std::endl;
    std::cout << "Restarts     : " << restarts << " (Average: " << (conflicts / restarts)
              << " Last: " << restarts << ")" << std::endl;
    std::cout << "Constraints  : Binary: " << binary << "% Ternary: " << ternary << "% Other: " 
              << (100.0 - binary - ternary) << "%" << std::endl;
    std::cout << "Cars         : " << cars << std::endl;
    std::cout << "Moves        : " << moves << std::endl;
    std::cout << "Occupied Cells: " << occupied_cell << std::endl;
    std::cout << "Three-Cell Cars: " << three_cell_cars << std::endl;
    std::cout << "Two-Cell Cars: " << two_cell_cars << std::endl;
}

void Resolver::resolve(const std::string &input, const std::string &logic, int n, bool vsids)
{
    if(n == 0) n = 1000;
    cars = occupied_cell = three_cell_cars = two_cell_cars = 0;
    getCarsInfo(input, cars, occupied_cell, three_cell_cars, two_cell_cars);

    // Construct the command with absolute paths
    std::string command;

    if(vsids){
        command = "clingo -n " + std::to_string(n) + " --parallel-mode=8 --heuristic=domain \"" + input + "\" \"" + logic + "\" --stats" +  " 2>/dev/null";;
    }else{
        command = "clingo -n " + std::to_string(n) + " --parallel-mode=8 \"" + input + "\" \"" + logic + "\" --stats" +  " 2>/dev/null";;
    }
    std::cout<<"Command: "<<command<<"\n";
    // Open the command for reading
    FILE *pipe = popen(command.c_str(), "r");
    if (!pipe)
        std::runtime_error("Failed to run clingo command.");

    std::string line;
    int max_calls = 10000;
    int call = 0;
    bool in_answer = false;
    int current_answer = 0;
    std::map<int, std::map<std::string, std::vector<std::string>>> grouped_atoms;
    all_answers.clear();
    all_answers.reserve(n);
    std::string summary;

    char buffer[4096];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr)
    {
        line = buffer;
        std::string trimmed = trim(line);

        if(line == "Solving...\n")
            call++;

        if(call == max_calls){
            pclose(pipe);
            throw std::runtime_error("Reached Max Calls : 10000/10000\n");
        }

        if (trimmed.empty())
        {
            continue;
        }

        if (trimmed.find("Answer:") == 0)
        {
            if (in_answer)
            {
                // Save the previous answer
                all_answers.push_back(grouped_atoms);
                grouped_atoms.clear();
            }
            in_answer = true;
        }
        else if (trimmed.find("SATISFIABLE") == 0 || trimmed.find("UNSATISFIABLE") == 0 ||
                 trimmed.find("Models") == 0 || trimmed.find("Calls") == 0 ||
                 trimmed.find("Time") == 0 || trimmed.find("CPU Time") == 0 ||
                 trimmed.find("Restarts") == 0 ||
                 trimmed.find("Constraints") == 0 || 
                 trimmed.find("Choices") == 0 || trimmed.find("Conflicts") == 0)
        {
            summary += trimmed + "\n";
        }
        else if (in_answer)
        {
            std::istringstream iss(trimmed);
            std::string atom;
            while (iss >> atom)
            {
                int T;
                std::string predicate, full_atom;
                if (parse_atom(atom, T, predicate, full_atom))
                {
                    grouped_atoms[T][predicate].push_back(full_atom);
                }
                else
                {
                    grouped_atoms[-1]["invalid"].push_back(atom);
                }
            }
        }
    }

    // After the loop, save the last answer if any
    if (in_answer && !grouped_atoms.empty())
    {
        all_answers.push_back(grouped_atoms);
    }

    moves = grouped_atoms.size();

    pclose(pipe);
    
    saveTime(summary);
}

void Resolver::getInfo(int &models, int &calls, float &time, float &solving, float &first_model, float &unsat, float &cpu_time, int& cars, int& three_cell_cars, int& two_cell_cars, int& moves, int& occupied_cell, float &choices, float &conflicts, float &restarts, float &binary, float &ternary)
{
    models = this->models;
    calls = this->calls;
    time = this->time;
    solving = this->solving;
    first_model = this->first_model;
    unsat = this->unsat;
    cpu_time = this->cpu_time;
    cars = this->cars;
    three_cell_cars = this->three_cell_cars;
    two_cell_cars = this->two_cell_cars;
    moves = this->moves;
    occupied_cell = this->occupied_cell;
    choices = this->choices;
    conflicts = this->conflicts;
    restarts = this->restarts;
    binary = this->binary;
    ternary = this->ternary;
}

void Resolver::save(const std::string &output)
{
    std::ofstream outFile(output);
    if (!outFile.is_open())
    {
        std::cerr << "Failed to open file for writing: "<< output <<" "<< strerror(errno) << std::endl;
        return;
    }

    // Iterate through all answers in the vector
    for (size_t i = 0; i < all_answers.size(); ++i)
    {
        outFile << "Answer: " << (i + 1) << std::endl;
        const auto &answer = all_answers[i];

        // Collect and sort the T values (keys in the outer map)
        std::vector<int> T_values;
        for (const auto &T_entry : answer)
        {
            T_values.push_back(T_entry.first);
        }
        std::sort(T_values.begin(), T_values.end());

        // Iterate through each T value and its corresponding predicates
        for (const auto &T : T_values)
        {
            outFile << "T = " << T << ":" << std::endl;
            const auto &predicates_map = answer.at(T);

            // Iterate through each predicate and its atoms
            for (const auto &[predicate, atoms] : predicates_map)
            {
                outFile << "  " << predicate << ": ";
                for (const auto &atom : atoms)
                {
                    outFile << atom << " ";
                }
                outFile << std::endl;
            }
            outFile << std::endl; // Extra line between groups
        }
        outFile << std::endl; // Extra line between answers
    }

    // Close the file
    outFile.close();
}
