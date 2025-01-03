#include <iostream>
#include <unistd.h>
#include <filesystem>
#include <string>
#include <stdexcept>
#include <getopt.h>
#include <fstream>
#include "resolver/Resolver.hh"
#include "gif_maker/GifCreater.hh"

std::string getFileName(const std::string &filePath)
{
    size_t pos = filePath.find_last_of("/\\"); // Find the last directory separator
    if (pos == std::string::npos)
    {
        return filePath; // If no separator is found, the whole path is the file name
    }
    return filePath.substr(pos + 1); // Return the part after the separator
}

void writeInfo(std::string file, std::string test_name, int models, int calls, float time, float solving, float first_model, float unsat, float cpu_time, int cars, int three_cell_cars, int two_cell_cars, int moves, int occupied_cell, float choices, float conflicts, float restarts, float binary, float ternary, bool use_heuristic, bool exist = false) {

    // Open the file in append mode if it exists, otherwise create it
    std::ofstream csvFile(file, exist ? std::ios::app : std::ios::out);

    if (!csvFile.is_open()) {
        std::cerr << "Error: Unable to open or create file " << file << std::endl;
        return;
    }

    // Write the header only if the file is being created
    if (!exist) {
        csvFile << "file,N_Models,Calls,CPU_Time,Time,Solving,First_Model,Unsat,Cars,Three_Cell_Car,Two_Cell_Car,Moves,Empty_Cells,Occupied_Cells,Choices,Conflicts,Restarts,Binary,Ternary,Heuristic \n";
    }

    // Write the data row
    csvFile << "\""<<test_name.c_str() << "\"," 
            << models << "," 
            << calls << "," 
            << cpu_time << "," 
            << time << "," 
            << solving << "," 
            << first_model << "," 
            << unsat << ","
            << cars << ","
            << three_cell_cars << ","
            << two_cell_cars << ","
            << moves << ","
            << 36 - occupied_cell << ","
            << occupied_cell << ","
            << choices << ","
            << conflicts << ","
            << restarts << ","
            << binary << ","
            << ternary << ","
            << use_heuristic
            << "\n";

    // Close the file
    csvFile.close();
}

std::string replaceExtension(const std::string &filename, const std::string &newExtension)
{
    size_t dotPosition = filename.find_last_of('.');
    if (dotPosition == std::string::npos)
    {
        // No extension found, append the new extension
        return filename + newExtension;
    }
    // Replace the extension
    return filename.substr(0, dotPosition) + newExtension;
}

bool alphanumericCompare(const std::string &a, const std::string &b)
{
    size_t i = 0, j = 0;

    while (i < a.size() && j < b.size())
    {
        if (std::isdigit(a[i]) && std::isdigit(b[j]))
        {
            // Extract numeric parts
            size_t start1 = i, start2 = j;

            while (i < a.size() && std::isdigit(a[i]))
                ++i;
            while (j < b.size() && std::isdigit(b[j]))
                ++j;

            int num1 = std::stoi(a.substr(start1, i - start1));
            int num2 = std::stoi(b.substr(start2, j - start2));

            if (num1 != num2)
                return num1 < num2;
        }
        else
        {
            // Compare characters case-insensitively
            char charA = std::tolower(a[i]);
            char charB = std::tolower(b[j]);

            if (charA != charB)
                return charA < charB;

            ++i;
            ++j;
        }
    }

    // If one string is a prefix of the other, the shorter string comes first
    return a.size() < b.size();
}

std::vector<std::string> listAspFiles(const std::string &folderPath)
{
    std::vector<std::string> aspFiles;
    namespace fs = std::filesystem;
    try
    {
        for (const auto &entry : fs::directory_iterator(folderPath))
        {
            if (entry.is_regular_file() && entry.path().extension() == ".asp")
            {
                aspFiles.push_back(entry.path().string());
            }
        }
    }
    catch (const fs::filesystem_error &ex)
    {
        std::cerr << "Error accessing directory: " << ex.what() << std::endl;
    }

    std::sort(aspFiles.begin(), aspFiles.end(), alphanumericCompare);
    return aspFiles;
}

std::string getFolderPath(const std::string &filePath)
{
    size_t pos = filePath.find_last_of("/\\"); // Find the last directory separator
    if (pos == std::string::npos)
    {
        return ""; // No separator found, return empty string
    }
    return filePath.substr(0, pos); // Return the part before the separator
}

// Helper function to get absolute path
std::string getAbsolutePath(const std::string &relativePath)
{
    char *absPath = realpath(relativePath.c_str(), nullptr);
    if (absPath == nullptr)
    {
        throw std::runtime_error("Failed to resolve absolute path.");
    }
    std::string absolutePath(absPath);
    free(absPath);
    return absolutePath;
}

void showHelp()
{
    std::cout << "Usage: ./main [OPTIONS]\n"
              << "Options:\n"
              << "  -i  <input file>                 Specify input file\n"
              << "  -F  <input folder>               Specify input folder\n"
              << "  -l  <logic file>                 Specify logic file\n"
              << "  -t  <info file>                  Specify file to store info\n"
              << "  -S  <solution folder>            Specify soltion folder\n"
              << "  -G  <output gif folder>          Specify soltion folder\n"
              << "  -h                               Show this help message\n";
}

void cmd_input(int argc, char *argv[], std::string &inputFile, std::string &inputFolder, std::string &logicFile, std::string &solutionFile, std::string &solutionFolder, std::string &infoFile, std::string &outputGif, bool &gen_gif)
{
    int opt;

    // Define the long options
    static struct option long_options[] = {
        {"input-file", required_argument, nullptr, 'i'},
        {"input-folder", required_argument, nullptr, 'F'},
        {"logic-file", required_argument, nullptr, 'l'},
        {"solution-folder", required_argument, nullptr, 'S'},
        {"timing-file", required_argument, nullptr, 't'},
        {"output-gif", required_argument, nullptr, 'G'},
        {"help", no_argument, nullptr, 'h'},
        {nullptr, 0, nullptr, 0}};

    // Parse the command line arguments using getopt_long
    while ((opt = getopt_long(argc, argv, "i:F:l:S:t:G:gh", long_options, nullptr)) != -1)
    {
        switch (opt)
        {
        case 'i':
            inputFile = optarg;
            break;
        case 'F':
            inputFolder = optarg;
            break;
        case 'l':
            logicFile = optarg;
            break;
        case 'S':
            solutionFolder = optarg;
            break;
        case 't':
            infoFile = optarg;
            break;
        case 'G':
            outputGif = optarg;
            break;
        case 'h':
            showHelp();
            return;
        default:
            showHelp();
            return;
        }
    }
}

int getOption(const std::string &inputFile,
              const std::string &inputFolder,
              const std::string &logicFile,
              const std::string &solutionFile,
              const std::string &solutionFolder,
              const std::string &outputGif,
              const bool gen_gif)
{

    if (inputFile.empty() && inputFolder.empty() && solutionFile.empty() && solutionFolder.empty())
    {
        std::cout << "Please provide Files.\n";
        return 0;
    }

    if (solutionFolder.empty())
    {
        std::cout << "Please provide a path to write/read solution.|n";
        return 0;
    }

    if (!inputFile.empty() && !logicFile.empty() && !outputGif.empty() && !solutionFolder.empty())
    {
        // calculate solution for file and create gif
        return 1;
    }

    if (!inputFolder.empty() && !logicFile.empty() && !outputGif.empty() && !solutionFolder.empty())
    {
        // calculate solution for entire folder and create gif
        return 2;
    }

    if (!inputFile.empty() && !logicFile.empty() && !solutionFolder.empty())
    {
        // calculate only solution for file
        return 3;
    }

    if (!inputFolder.empty() && !logicFile.empty() && !solutionFolder.empty())
    {
        // calculate only solution for entire folder
        return 4;
    }

    if (!inputFile.empty() && !solutionFolder.empty() && !outputGif.empty())
    {
        // only generate gif for entire file by sol folder
        return 6;
    }

    if (!inputFolder.empty() && !solutionFolder.empty() && !outputGif.empty())
    {
        // only generate gif for entire folder
        return 7;
    }

    return 0;
}

int main(int argc, char *argv[])
{
    GifCreater generator;
    int n_models = 1;
    bool use_h = true;
    std::string inputFile, inputFolder, logicFile, solutionFile, solutionFolder, infoFile, outputGif;
    bool gen_gif = false;

    cmd_input(argc, argv, inputFile, inputFolder, logicFile, solutionFile, solutionFolder, infoFile, outputGif, gen_gif);

    int op = getOption(inputFile, inputFolder, logicFile, solutionFile, solutionFolder, outputGif, gen_gif);

    if (!op)
    {
        return 0;
    }

    if (op == 3 || op == 1)
    {
        Resolver &resolver = Resolver::getInstance();
        inputFile = getAbsolutePath(inputFile);
        logicFile = getAbsolutePath(logicFile);
        if(!infoFile.empty()){
           infoFile = getFolderPath(infoFile)+ "/"+ getFileName(infoFile);
        }
        std::cout << "Resolving Problem.\n";
        resolver.resolve(inputFile, logicFile, n_models, use_h);
        std::cout << "Problem resolved.\n\n";
        std::string solutionFolder1 = getAbsolutePath(solutionFolder) + "/solution_" + getFileName(inputFile);
        std::cout << "Saving Solution.\n";
        resolver.save(solutionFolder1);
        std::cout << "Solution Saved.\n\n";
        if(!infoFile.empty()){
            std::cout << "Saving Time. \n";
            int models, calls;
            float solving, first_model, unsat, cpu_time, time;
            float choices, conflicts, restarts, binary, ternary;
            int cars, moves, occupied_cell, three_cell_cars, two_cell_cars;
                            
            resolver.getInfo(models, calls, time, solving, first_model, unsat, cpu_time, cars, three_cell_cars, two_cell_cars, moves, occupied_cell, choices, conflicts, restarts, binary, ternary);
            writeInfo(infoFile, getFileName(inputFile), models, calls, time, solving, first_model, unsat, cpu_time, cars, three_cell_cars, two_cell_cars, moves, occupied_cell, choices, conflicts, restarts, binary, ternary, use_h);
            std::cout << "Time Saved. \n";
        }
    }

    if (op == 4 || op == 2)
    {
        Resolver &resolver = Resolver::getInstance();
        std::vector<std::string> files = listAspFiles(getAbsolutePath(inputFolder));
        logicFile = getAbsolutePath(logicFile);
        std::string current_file;
        std::string current_output_file;
        if(!infoFile.empty()){
           infoFile = getFolderPath(infoFile)+ "/"+ getFileName(infoFile);
        }
        solutionFolder = getAbsolutePath(solutionFolder);
        bool exists = false;
        int models, calls;
        float time, solving, first_model, unsat, cpu_time; 
        float choices, conflicts, restarts, binary, ternary;
        int cars, moves, occupied_cell, three_cell_cars, two_cell_cars;
        for (auto &file : files)
        {
            current_file = getFileName(file);
            current_output_file = solutionFolder + "/solution_" + current_file;
            std::cout << "*************************\n";

            std::cout << "Resolving Problem: " << current_file << "\n";
            resolver.resolve(file, logicFile, n_models, use_h);
            std::cout << "Problem resolved: " << current_file << "\n\n";

            std::cout << "Saving Solution: " << current_file << "\n";
            resolver.save(current_output_file);
            std::cout << "Solution Saved: " << current_file << "\n\n";
            
            if(!infoFile.empty()){
                std::cout << "Saving Time. \n";
                
                resolver.getInfo(models, calls, time, solving, first_model, unsat, cpu_time, cars, three_cell_cars, two_cell_cars, moves, occupied_cell, choices, conflicts, restarts, binary, ternary);
                writeInfo(infoFile, getFileName(current_file), models, calls, time, solving, first_model, unsat, cpu_time, cars, three_cell_cars, two_cell_cars, moves, occupied_cell, choices, conflicts, restarts, binary, ternary, use_h, exists);
                exists = true;
                std::cout << "Time Saved. \n";
            }
            std::cout << "*************************\n\n";
        }

        std::cout << "All Probles are Solved.\n";
    }

    if (op == 6 || op == 1)
    {
        std::vector<std::string> solution_files = listAspFiles(getAbsolutePath(solutionFolder));
        std::string current_file;
        std::string current_output_file;

        for (int j = 0; j < solution_files.size(); j++)
        {
            auto &solution_file = solution_files[j];
            if (getFileName(solution_file).find(getFileName(inputFile)) != std::string::npos)
            {
                current_file = getFileName(inputFile);
                current_output_file = getAbsolutePath(outputGif) + "/" + replaceExtension(getFileName(solution_file), ".gif");
                std::cout << "*************************\n";
                std::cout << "Creating Gif: " << current_file << "\n";
                generator.create(inputFile, solution_file, 1);
                std::cout << "Gif created: " << current_file << "\n";
                std::cout << "Saving Gif: " << current_file << "\n";
                generator.save(current_output_file);
                std::cout << "Gif Saved: " << current_file << "\n";
                std::cout << "*************************\n\n";
                break;
            }
        }
        return 0;
    }

    if (op == 7 || op == 2)
    {
        std::vector<std::string> input_files = listAspFiles(getAbsolutePath(inputFolder));
        std::vector<std::string> solution_files = listAspFiles(getAbsolutePath(solutionFolder));
        std::string current_file;
        std::string current_output_file;

        for (int i = 0; i < input_files.size(); i++)
        {
            auto &input_file = input_files[i];
            for (int j = 0; j < solution_files.size(); j++)
            {
                auto &solution_file = solution_files[j];
                if (getFileName(solution_file).find(getFileName(input_file)) != std::string::npos)
                {
                    current_file = getFileName(input_file);
                    current_output_file = getAbsolutePath(outputGif) + "/" + replaceExtension(getFileName(solution_file), ".gif");
                    std::cout << "*************************\n";
                    std::cout << "Creating Gif: " << current_file << "\n";
                    generator.create(input_file, solution_file, 1);
                    std::cout << "Gif created: " << current_file << "\n";
                    std::cout << "Saving Gif: " << current_file << "\n";
                    generator.save(current_output_file);
                    std::cout << "Gif Saved: " << current_file << "\n";
                    std::cout << "*************************\n\n";
                    break;
                }
            }
        }

        std::cout << "All gif are created.\n";
        return 0;
    }

    return 0;
}
