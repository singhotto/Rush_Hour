// g++ -std=c++17 parser.cpp -o parser

#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include <unordered_map>
#include <string>
#include <algorithm> // For sorting
#include <random>

struct Car {
    int id;            // Car ID (0 to number of cars)
    char symbol;       // Symbol representing the car (A-Z)
    int size;          // Size of the car (2 or 3)
    char orientation;  // Orientation: 'H' (horizontal) or 'V' (vertical)
    int row, col;      // Starting position (row, column)
};

int getRandomNumber(int min, int max) {
    // Create a random engine and a distribution for the range
    std::random_device rd;
    std::mt19937 gen(rd()); // Mersenne Twister engine seeded with random device
    std::uniform_int_distribution<> dist(min, max);

    // Return the random number in the specified range
    return dist(gen);
}

std::string getLineFromFile(std::fstream& file, int lineNumber) {
    std::string line;
    int currentLine = 1;
    file.clear();  // Clear any error flags
    file.seekg(0, std::ios::beg);  // Move the pointer to the beginning

    while (std::getline(file, line)) {
        if (currentLine == lineNumber) {
            return line;
        }
        currentLine++;
    }

    return ""; // If the line isn't found
}

std::string getSecondString(const std::string& line) {
    std::istringstream stream(line);
    std::string word;

    // Skip the first word
    stream >> word;

    // Extract and return the second word
    if (stream >> word) {
        return word;
    }

    return "";
}

std::vector<std::string> getPositions(std::string filename, int size, bool expert = false){
    std::fstream file(filename, std::ios::in);

    std::vector<std::string> pos;
    pos.reserve(size);

    if (!file.is_open()) {
        std::cerr << "Error: Could not open file!" << std::endl;
        return pos;
    }

    int min = 1;
    int max = 100;

    if(expert){
        min = 1;
        max = 500;
    }else{
        min = 4000;
        max = 8000;
    }

    std::vector<int> ln;
    ln.reserve(size);
    bool isUnique = false;

    for(int i = 0; i<size; i++){
        isUnique = false;
        while(!isUnique){
            int randomNum = getRandomNumber(min, max);
            if (std::find(ln.begin(), ln.end(), randomNum) == ln.end()) {
                ln.push_back(randomNum);
                isUnique = true;
            }
        }
        int lineNumber = ln.back();
        std::string line = getLineFromFile(file, lineNumber);
        if (!line.empty()) {
            std::string position = getSecondString(line);
            pos.push_back(position);
        }
    }

    // Close the file when done
    file.close();
    return pos;
}

std::vector<Car> parseRushHour(const std::string& board) {
    const int gridSize = 6; // Assuming a 6x6 grid
    std::vector<std::vector<char>> grid(gridSize, std::vector<char>(gridSize, 'o'));
    
    // Fill the grid with the input string
    for (int i = 0; i < board.size(); ++i) {
        grid[i / gridSize][i % gridSize] = board[i];
    }

    std::unordered_map<char, Car> cars;

    // Traverse the grid to identify cars and their properties
    for (int r = 0; r < gridSize; ++r) {
        for (int c = 0; c < gridSize; ++c) {
            char cell = grid[r][c];
            if (cell == 'o' || cell == 'x') {
                continue; // Skip empty cells and walls
            }

            // If the car is not already recorded, initialize it
            if (cars.find(cell) == cars.end()) {
                cars[cell] = {0, cell, 0, 'h', r + 1, c + 1}; // Adjust row and column to start from 1
            }

            // Check the car's orientation and size
            Car& car = cars[cell];
            car.size++;
            if (r + 1 < gridSize && grid[r + 1][c] == cell) {
                car.orientation = 'v';
            }
        }
    }

    // Assign IDs to cars, ensuring the red car ('A') gets ID 0
    std::vector<Car> carList;
    for (const auto& pair : cars) {
        carList.push_back(pair.second);
    }

    std::sort(carList.begin(), carList.end(), [](const Car& a, const Car& b) {
        return a.symbol == 'A' ? true : (b.symbol == 'A' ? false : a.symbol < b.symbol);
    });

    int currentId = 1; // Start IDs from 1
    for (auto& car : carList) {
        if (car.symbol == 'A') {
            car.id = 0; // Red car gets ID 0
        } else {
            car.id = currentId++;
        }
    }

    return carList;
}

void writeFile(std::string& filename, std::vector<Car>& cars){

    // Open file for writing (will overwrite if file exists)
    std::ofstream outfile(filename);

    if (!outfile) {
        std::cerr << "Error opening file for writing!" << std::endl;
        return;
    }

    // Write the parsed cars to the file
    for (const auto& car : cars) {
        outfile << "car(" << car.id << ", " << car.size << ", "
                << car.orientation << ", (" << car.row << ", " << car.col << ")).\n";
    }
    
    outfile << "\n";  // Add a newline at the end

    outfile << "dim((1..6, 1..6)).\n";

    outfile << "exit(0, (3, 5)).\n";

    outfile << "\n";  // Add a newline at the end
    // Close the file
    outfile.close();
}

int main() {

    //change both
    bool expert = true;
    int start = 11;


    std::string outFile;
    if(expert){
        outFile = "../input/input_expert_";

    }else{
        outFile = "../input/input_advance_";
    }
    std::vector<std::string> positions = getPositions("rush.txt", 100, expert);

    for(auto pos : positions){
        std::vector<Car> cars = parseRushHour(pos);
        std::string outputFile = outFile + std::to_string(start)+".asp";
        writeFile(outputFile, cars);
        start++;
    }

    return 0;
}
