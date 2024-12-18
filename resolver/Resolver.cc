#include "Resolver.hh"
#include <fstream>
#include <cerrno>
#include <cstring>
#include <cstdlib>

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

void Resolver::resolve(const std::string &input, const std::string &logic, int n)
{
    if(n == 0) n = 1000;

    // Construct the command with absolute paths
    std::string command = "clingo -n 0 \"" + input + "\" \"" + logic + "\"";
    std::cout << "Command: " << command << std::endl;
    // Open the command for reading
    FILE *pipe = popen(command.c_str(), "r");
    if (!pipe)
        std::runtime_error("Failed to run clingo command.");

    std::string line;
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
            if(all_answers.size() == n)
                break;
        }
        else if (trimmed.find("SATISFIABLE") == 0 || trimmed.find("UNSATISFIABLE") == 0 ||
                 trimmed.find("Models") == 0 || trimmed.find("Calls") == 0 ||
                 trimmed.find("Time") == 0 || trimmed.find("CPU Time") == 0)
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

    pclose(pipe);
}

void Resolver::save(const std::string &output)
{
    std::ofstream outFile(output);
    if (!outFile.is_open())
    {
        std::cerr << "Failed to open file for writing: " << strerror(errno) << std::endl;
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
