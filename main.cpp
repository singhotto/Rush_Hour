#include <iostream>
#include <unistd.h>
#include <string>
#include <stdexcept>
#include <getopt.h>
#include "resolver/Resolver.hh"
#include "gif_maker/GifCreater.hh"


std::string getFolderPath(const std::string &filePath)
{
    size_t pos = filePath.find_last_of("/\\"); // Find the last directory separator
    if (pos == std::string::npos)
    {
        return ""; // No separator found, return empty string
    }
    return filePath.substr(0, pos); // Return the part before the separator
}

std::string getFileName(const std::string &filePath)
{
    size_t pos = filePath.find_last_of("/\\"); // Find the last directory separator
    if (pos == std::string::npos)
    {
        return filePath; // If no separator is found, the whole path is the file name
    }
    return filePath.substr(pos + 1); // Return the part after the separator
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

void showHelp() {
    std::cout << "Usage: ./main [OPTIONS]\n"
              << "Options:\n"
              << "  -i  <input file>                  Specify input file\n"
              << "  -F <input folder>                Specify input folder\n"
              << "  -l  <logic file>                  Specify logic file\n"
              << "  -s  <solution file>               Specify soltion file\n"
              << "  -S <solution folder>             Specify soltion folder\n"
              << "  -o <output solution folder>      Specify soltion folder\n"
              << "  -g                                Generate gif\n"
              << "  -G <output gif folder>            Specify soltion folder\n"
              << "  -h                                Show this help message\n";
}

void cmd_input(int argc, char* argv[], std::string& inputFile, std::string& inputFolder, std::string& logicFile, std::string& solutionFile, std::string& solutionFolder, std::string& outputSolution, std::string& outputGif, bool& gen_gif) {
    int opt;
    
    // Define the long options
    static struct option long_options[] = {
        {"input-file", required_argument, nullptr, 'i'},
        {"input-folder", required_argument, nullptr, 'f'},
        {"logic-file", required_argument, nullptr, 'l'},
        {"solution-file", required_argument, nullptr, 's'},
        {"solution-folder", required_argument, nullptr, 'F'},
        {"output-solution", required_argument, nullptr, 'o'},
        {"output-gif", required_argument, nullptr, 'G'},
        {"gen-gif", no_argument, nullptr, 'g'},
        {"help", no_argument, nullptr, 'h'},
        {nullptr, 0, nullptr, 0}
    };

    // Parse the command line arguments using getopt_long
    while ((opt = getopt_long(argc, argv, "i:f:l:s:F:o:G:gh", long_options, nullptr)) != -1) {
        switch (opt) {
            case 'i':
                inputFile = optarg;
                break;
            case 'F':
                inputFolder = optarg;
                break;
            case 'l':
                logicFile = optarg;
                break;
            case 's':
                solutionFile = optarg;
                break;
            case 'S':
                solutionFolder = optarg;
                break;
            case 'o':
                outputSolution = optarg;
                break;
            case 'G':
                outputGif = optarg;
                break;
            case 'g':
                gen_gif = true;
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

int getOption(const std::string& inputFile, 
                   const std::string& inputFolder, 
                   const std::string& logicFile, 
                   const std::string& solutionFile, 
                   const std::string& solutionFolder, 
                   const std::string& outputSolution, 
                   const std::string& outputGif,
                   const bool gen_gif) {

    if ((!inputFile.empty() || !inputFolder.empty()) && (!solutionFile.empty() || !solutionFolder.empty())) {
        std::cout<<"Cannot specify both input and solution.\n";
        return 0;
    }

    if (inputFile.empty() && inputFolder.empty() && solutionFile.empty() && solutionFolder.empty()) {
        std::cout<<"Please provide Files.\n";
        return 0;
    }

    if ((!inputFile.empty() || !inputFolder.empty()) && logicFile.empty()) {
        std::cout<<"Input provided, but Logic File is missing.\n";
        return 0;
    }

    if((!solutionFile.empty() || !solutionFolder.empty()) && outputGif.empty()){
        std::cout<<"Please provide Path to save gif.\n";
        return 0;
    }

    if((!inputFile.empty() || !inputFolder.empty())&& gen_gif && outputGif.empty()){
        std::cout<<"Please provide Path to save gif.\n";
        return 0;
    }

    if(!inputFile.empty()){
        return 1;
    }

    if(!inputFolder.empty()){
        return 2;
    }

    if(!solutionFile.empty()){
        return 3;
    }

    if(!solutionFolder.empty()){
        return 4;
    }
}

int main(int argc, char* argv[]) {
    std::string inputFile, inputFolder, logicFile, solutionFile, solutionFolder, outputSolution, outputGif;
    bool gen_gif = false;

    cmd_input(argc, argv, inputFile, inputFolder, logicFile, solutionFile, solutionFolder, outputSolution, outputGif, gen_gif);
    
    int op = getOption(inputFile, inputFolder, logicFile, solutionFile, solutionFolder, outputSolution, outputGif, gen_gif);

    std::cout<<op<<"\n";
    if(!op){
        return 0;
    }

    if(op == 1){
        Resolver& resolver =  Resolver::getInstance();
        inputFile = getAbsolutePath(inputFile);
        logicFile = getAbsolutePath(logicFile);
        resolver.resolve(inputFile, logicFile);
        outputSolution = getAbsolutePath(getFolderPath(outputSolution)) + "/" + getFileName(outputSolution);
        resolver.save(outputSolution);
    }

    if(gen_gif || !outputGif.empty()){
        GifCreater generator;
        generator.create(inputFile, outputSolution, 5);
        generator.save(outputGif);
    }

    return 0;
}
