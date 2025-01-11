## Build Instructions

cd build

cmake ..

make clean

make

## Usage

### Single File: Calculate Answer, Generate GIF, and Store

./main -i ../input/input_beginner_2.asp -l ../asp/rush_hour.asp -S ../solutions -G ../output

### Folder: Calculate Answer and Save Time

./main -F ../input -l ../asp/rush_hour.asp -S ../solutions -t ../data/test.csv

### Single File: Store Execution Time

./main -i ../input/input_beginner_2.asp -l ../asp/rush_hour.asp -S ../solutions -t ../data/test.csv

### Folder: Store Execution Time

./main -F ../input -l ../asp/rush_hour.asp -S ../solutions -t ../data/test.csv

### Single File: Generate and Store GIF

./main -i ../input/input_beginner_2.asp -S ../solutions -G ../output

### Folder: Generate and Store GIFs

./main -F ../input -S ../solutions -G ../output

