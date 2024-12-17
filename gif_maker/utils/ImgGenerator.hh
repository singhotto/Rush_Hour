#ifndef IMG_GENERATOR_HH
#define IMG_GENERATOR_HH

#include "../lib/stb_image.h"

#include <iostream>
#include <vector>

class ImgGenerator
{
private:
    struct Move
    {
        int car_id;
        std::pair<int, int> from;
        std::pair<int, int> to;
        Move(std::pair<int, int> from, std::pair<int, int> to, int car_id)
        {
            this->from = from;
            this->to = to;
            this->car_id = car_id;
        }

        void print()
        {
            std::cout << "move(" << car_id << ", (" << from.first << ", " << from.second << ", (" << to.first << ", " << to.second << "))";
        }
    };

    struct Init
    {
        int id;
        std::pair<int, int> pos;
        int len;
        bool v;
        Init(int id, std::pair<int, int> pos, int len, bool v = true)
        {
            this->id = id;
            this->pos = pos;
            this->len = len;
            this->v = v;
        }

        void print()
        {
            std::cout << "car(" << id << ", (" << pos.first << ", " << pos.second << "), " << len << ", " << v << ")";
        }
    };

    struct Coordinates
    {
        int sx, sy, ex, ey;

        void print()
        {
            std::cout << "pos((" << sx << ", " << sy << "), (" << ex << ", " << ey << "))";
        }
    };

    int gif_width;
    int gif_height;
    const int moveSpeed = 5;
    std::vector<uint8_t> grid;
    std::vector<Init> init_cars;
    std::vector<Move> moves;
    std::vector<std::vector<uint8_t>> cars;
    std::vector<std::vector<uint8_t>> images;

    std::vector<uint8_t> getGrid();
    Init getCar(int id);

    std::vector<uint8_t> loadImg(std::string path, bool alph = true);

    void resetPixel(int fx, int fy, int tx, int ty, std::vector<uint8_t> &original);
    void replacePixel(int fx, int fy, int tx, int ty, std::vector<uint8_t> &original, std::vector<uint8_t> &dataImg);
    Coordinates getCoordinates(int pos_x, int pos_y, int size, bool ver);
    std::vector<uint8_t> getCarImg(int i, int s, bool v);

    void init();
    void renderMoves();
    void moveCar(int id, Coordinates from, Coordinates to, int car_size, bool v = true);

    void createGif();

public:
    ImgGenerator(std::string init_path, std::string move_path);
    ~ImgGenerator() = default;

    void generate();
};

#endif