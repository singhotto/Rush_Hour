#include <iostream>
#include <string>
#include <map>
#include <vector>
#include <cstdlib>
#include <cstdio>
#include <sstream>
#include <algorithm>

// Function to trim whitespace from both ends of a string
std::string trim(const std::string& s) {
    size_t start = s.find_first_not_of(" \t\r\n");
    size_t end = s.find_last_not_of(" \t\r\n");
    if (start == std::string::npos) return "";
    return s.substr(start, end - start + 1);
}

// Function to parse an atom and extract T and the atom string
bool parse_atom(const std::string& atom, int& T, std::string& predicate, std::string& full_atom) {
    size_t first_paren = atom.find('(');
    size_t comma = atom.find(',', first_paren);
    if (first_paren == std::string::npos || comma == std::string::npos)
        return false;
    
    std::string T_str = atom.substr(first_paren + 1, comma - first_paren - 1);
    try {
        T = std::stoi(trim(T_str));
    } catch (...) {
        return false;
    }
    
    predicate = trim(atom.substr(0, first_paren)); // Extract the predicate name
    full_atom = trim(atom); // Store the full atom for later use
    return true;
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " <clingo_file.asp> <clingo_file.asp>" << std::endl;
        return 1;
    }



    std::string filename1 = argv[1];
    std::string filename2 = argv[2];
    std::string command = "clingo -n 0 " + filename1 + " " + filename2;

    // Open the command for reading
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) {
        std::cerr << "Failed to run clingo command." << std::endl;
        return 1;
    }

    std::string line;
    bool in_answer = false;
    int current_answer = 0;
    std::map<int, std::map<std::string, std::vector<std::string>>> grouped_atoms;
    std::vector<std::map<int, std::map<std::string, std::vector<std::string>>>> all_answers;
    std::string summary;

    char buffer[4096];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        line = buffer;
        std::string trimmed = trim(line);

        if (trimmed.empty()) {
            continue;
        }

        if (trimmed.find("Answer:") == 0) {
            if (in_answer) {
                // Save the previous answer
                all_answers.push_back(grouped_atoms);
                grouped_atoms.clear();
            }
            in_answer = true;
        } else if (trimmed.find("SATISFIABLE") == 0 || trimmed.find("UNSATISFIABLE") == 0 ||
                   trimmed.find("Models") == 0 || trimmed.find("Calls") == 0 ||
                   trimmed.find("Time") == 0 || trimmed.find("CPU Time") == 0) {
            summary += trimmed + "\n";
        } else if (in_answer) {
            std::istringstream iss(trimmed);
            std::string atom;
            while (iss >> atom) {
                int T;
                std::string predicate, full_atom;
                if (parse_atom(atom, T, predicate, full_atom)) {
                    grouped_atoms[T][predicate].push_back(full_atom);
                } else {
                    grouped_atoms[-1]["invalid"].push_back(atom);
                }
            }
        }
    }

    // After the loop, save the last answer if any
    if (in_answer && !grouped_atoms.empty()) {
        all_answers.push_back(grouped_atoms);
    }

    pclose(pipe);

    // Print all answers
    for (size_t i = 0; i < all_answers.size(); ++i) {
        std::cout << "Answer: " << (i + 1) << std::endl;
        const auto& answer = all_answers[i];
        std::vector<int> T_values;
        for (const auto& T_entry : answer) {
            T_values.push_back(T_entry.first);
        }
        std::sort(T_values.begin(), T_values.end());

        for (const auto& T : T_values) {
            std::cout << "T = " << T << ":" << std::endl;
            const auto& predicates_map = answer.at(T);
            for (const auto& [predicate, atoms] : predicates_map) {
                std::cout << "  " << predicate << ": ";
                for (const auto& atom : atoms) {
                    std::cout << atom << " ";
                }
                std::cout << std::endl;
            }
            std::cout << std::endl; // Extra line between groups
        }
        std::cout << std::endl; // Extra line between answers
    }

    // Print the summary
    if (!summary.empty()) {
        std::cout << summary;
    }

    return 0;
}
