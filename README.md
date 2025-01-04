./main -i ../input/input4.asp -l ../asp/rush_hour.asp -S ../solutionsasp -G ../output

//store time for folder
./main -F ../input -l ../asp/rush_hour.asp -S ../solutions -t ../data/test.csv

//store time for file
./main -i ../input/input2.asp -l ../asp/rush_hour.asp -S ../solutions -t ../data/test.csv

//current
./main -F ../input -l ../asp/rush_hour.asp -S ../solutions -t ../data/test_expert_.csv

--parallel-mode=4

--heuristic=vsids

--stats

find . -type f \( -name "*advance*" -o -name "*expert*" \) -exec rm -f {} \;
