#include "ImgGenerator.hh"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <regex>
#include <stdexcept>
#include <algorithm>

#include "gif.h"

std::vector<uint8_t> ImgGenerator::getGrid()
{
    grid = loadImg("/grid.png", false);
    return grid;
}

ImgGenerator::Init ImgGenerator::getCar(int id)
{
    for (auto x : init_cars)
    {
        if (x.id == id)
            return x;
    }
    throw std::runtime_error("Car id: " + std::to_string(id) + " Not found!!");
}

std::vector<uint8_t> ImgGenerator::loadImg(std::string path, bool alph)
{
    int w;
    int h;
    int channels;
    unsigned char *img_data;

    std::string file_path = std::string(RESOURCE_DIR) + path;
    if (alph)
    {
        img_data = stbi_load(file_path.c_str(), &w, &h, &channels, STBI_rgb_alpha); // Change to RGBA
    }
    else
    {
        img_data = stbi_load(file_path.c_str(), &w, &h, &channels, STBI_rgb); // Change to RGBA
    }

    // Check if the image was loaded successfully
    if (img_data == nullptr)
    {
        throw std::runtime_error("Failed to load grid.");
    }

    if (images.size() == 0)
    {
        gif_width = w;
        gif_height = h;
    }

    if (0)
    {
        std::cout << "Dimensions: w: " << w << ", h: " << h << ", c: " << channels << "\n";
    }

    // Initialize a grid of RGBA pixels
    std::vector<uint8_t> grid(w * h * 4, 255);

    // Copy image data to grid (with RGBA values)
    int ss = 0;
    for (int y = 0; y < h; ++y)
    {
        for (int x = 0; x < w; ++x)
        {
            unsigned char *pixel = img_data + (y * w + x) * channels;
            grid[ss++] = pixel[0]; // Red
            grid[ss++] = pixel[1]; // Green
            grid[ss++] = pixel[2]; // Blue
            grid[ss++] = 255;      // Alpha (fully opaque)
        }
    }

    // Free the image memory
    stbi_image_free(img_data);

    return grid;
}
void ImgGenerator::resetPixel(int fx, int fy, int tx, int ty,
                              std::vector<uint8_t> &original)
{
    // Calculate the inclusive height and width
    int img_h = ty - fy;
    int img_w = tx - fx;

    if (0)
    {
        std::cout << "fx: " << fx << " fy: " << fy << " tx: " << tx << " ty: " << ty << "\n";
    }

    // Loop over the region to copy pixels
    for (int y = 0; y < img_h; ++y)
    {
        int srcRowIdx = (fy + y) * this->gif_width; // Source row start index

        for (int x = 0; x < img_w; ++x)
        {
            int pixelIdx = (srcRowIdx + fx + x) * 4;

            for (int i = 0; i < 3; ++i)
            {
                original[pixelIdx + i] = grid[pixelIdx + i];
            }
        }
    }
}

void ImgGenerator::replacePixel(int fx, int fy, int tx, int ty,
                                std::vector<uint8_t> &original,
                                std::vector<uint8_t> &dataImg)
{
    int img_h = ty - fy;
    int img_w = tx - fx;

    if (0)
    {
        std::cout << "fx: " << fx << " fy: " << fy << " tx: " << tx << " ty: " << ty << "\n";
    }

    // Loop over the region to replace
    for (int y = 0; y < img_h; ++y)
    {
        int s_y = y * img_w;
        int d_y = (fy + y) * this->gif_width;
        for (int x = 0; x < img_w; ++x)
        {
            int srcIdx = (s_y + x) * 4;
            int dstIdx = (d_y + fx + x) * 4;

            for (int i = 0; i < 3; i++)
            {
                original[dstIdx + i] = dataImg[srcIdx + i];
            }
        }
    }
}

ImgGenerator::Coordinates ImgGenerator::getCoordinates(int pos_x, int pos_y, int size, bool ver)
{
    Coordinates c;
    c.sx = pos_y - 1;
    c.sy = pos_x - 1;

    c.sy *= 150;
    c.sx *= 150;

    if (ver)
    {
        c.ex = 150 + c.sx;
        c.ey = 150 * size + c.sy;
    }
    else
    {
        c.ex = 150 * size + c.sx;
        c.ey = 150 + c.sy;
    }
    return c;
}

void ImgGenerator::createGif()
{
    // Create and write the GIF
    auto fileName = "../output.gif";
    int delay = 10;
    GifWriter g;
    GifBegin(&g, fileName, gif_width, gif_height, delay);
    for (auto &img : images)
    {
        GifWriteFrame(&g, img.data(), gif_width, gif_height, delay);
    }
    GifEnd(&g);
}

ImgGenerator::ImgGenerator(std::string init_path, std::string move_path)
{

    std::ifstream file(init_path);
    std::string line;
    if (file.is_open())
    {
        // Regular expression to match the move format in the file1
        std::regex carRegex(R"(\s*car\(\s*(\d+)\s*,\s*(\d+)\s*,\s*([hv])\s*,\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)\s*\)\.)");
        std::smatch match;

        // Iterate over the entire line and match each move pattern
        while (std::getline(file, line))
        {
            while (std::regex_search(line, match, carRegex))
            {
                int car = std::stoi(match[1].str());
                int car_l = std::stoi(match[2].str());
                bool car_d = (match[3].str())[0] == 'v' ? true : false;
                int x = std::stoi(match[4].str());
                int y = std::stoi(match[5].str());
                
                // Add the parsed move to the vector
                init_cars.push_back(Init(car, std::pair<int, int>(x, y), car_l, car_d));
                // Move to the next match in the line
                line = match.suffix().str();
            }
        }
        file.close();
    }
    else
    {
        std::cerr << "Failed to open the file " << init_path << "\n";
    }
    std::regex moveRegex(R"(\s*move\((\d+),\((\d+),(\d+)\),\((\d+),(\d+)\),(\d+)\))");

    std::ifstream file1(move_path);
    if (file1.is_open())
    {
        // Regular expression to match the move format in the file1
        std::regex moveRegex(R"(\s*move\((\d+),\((\d+),(\d+)\),\((\d+),(\d+)\),(\d+)\))");
        std::smatch match;

        // Iterate over the entire line and match each move pattern
        while (std::getline(file1, line))
        {
            while (std::regex_search(line, match, moveRegex))
            {
                // Parse each captured group
                int vector_index = std::stoi(match[1].str());
                int from_x = std::stoi(match[2].str());
                int from_y = std::stoi(match[3].str());
                int to_x = std::stoi(match[4].str());
                int to_y = std::stoi(match[5].str());
                int car_id = std::stoi(match[6].str());

                // Store the move
                moves.emplace_back(Move{{from_x, from_y}, {to_x, to_y}, car_id});
                line = match.suffix().str();
            }
        }
        file1.close();
    }
    else
    {
        std::cerr << "Failed to open the file " << move_path << "\n";
    }
}

std::vector<uint8_t> ImgGenerator::getCarImg(int i, int s, bool v)
{
    i++;
    std::vector<uint8_t> data;
    if (v)
    {
        if (s == 2)
        {
            data = loadImg("/cars/vertical/car_2_" + std::to_string(i) + ".png");
        }
        else
        {
            data = loadImg("/cars/vertical/car_3_" + std::to_string(i) + ".png");
        }
    }
    else
    {
        if (s == 2)
        {
            data = loadImg("/cars/horizontal/car_2_" + std::to_string(i) + "_h.png");
        }
        else
        {
            data = loadImg("/cars/horizontal/car_3_" + std::to_string(i) + "_h.png");
        }
    }

    return data;
}

void ImgGenerator::init()
{
    images.push_back(getGrid());

    int i = 0;
    cars.reserve(init_cars.size());
    for (auto x : init_cars)
    {
        Coordinates c = getCoordinates(x.pos.first, x.pos.second, x.len, x.v);

        cars.push_back(getCarImg(i, x.len, x.v));
        replacePixel(c.sx, c.sy, c.ex, c.ey, images.back(), cars.back());
        i++;
    }
}

void ImgGenerator::renderMoves()
{
    for (auto x : moves)
    {
        Init c = getCar(x.car_id);
        Coordinates from = getCoordinates(x.from.first, x.from.second, c.len, c.v);
        Coordinates to = getCoordinates(x.to.first, x.to.second, c.len, c.v);

        moveCar(x.car_id, from, to, c.len, c.v);
    }
}

void ImgGenerator::moveCar(int id, Coordinates from, Coordinates to, int car_size, bool v)
{
    if (0)
    {
        from.print();
        std::cout << "\n";
        to.print();
        std::cout << "\n";
    }
    if (v)
    {
        if (from.sy < to.sy)
        {
            // downward
            int car_size = from.ey - from.sy;
            int movement_size = to.sy - from.sy;
            int movement = movement_size / moveSpeed;
            int start = from.sy;
            int end = to.sy;
            for (int i = start; i < end; i += movement)
            {
                images.push_back(images.back());
                int tt = i + movement;
                resetPixel(from.sx, i, from.ex, tt, images.back());
                replacePixel(from.sx, tt, from.ex, tt + car_size, images.back(), cars[id]);
            }
        }
        else
        {
            // upward
            int car_size = from.ey - from.sy;
            int movement_size = from.sy - to.sy;
            int movement = movement_size / moveSpeed;
            int start = from.sy;
            int end = to.sy;
            for (int i = start; i > end; i -= movement)
            {
                images.push_back(images.back());
                int tt = i - movement;
                resetPixel(from.sx, tt + car_size, from.ex, i + car_size, images.back());
                replacePixel(from.sx, tt, from.ex, tt + car_size, images.back(), cars[id]);
            }
        }
    }
    else
    {
        if (from.sx < to.sx)
        {
            int car_size = from.ex - from.sx;
            int movement_size = to.sx - from.sx;
            int movement = movement_size / moveSpeed;
            int start = from.sx;
            int end = to.sx;
            for (int i = start; i < end; i += movement)
            {
                images.push_back(images.back());
                int ei = i + movement;
                resetPixel(i, from.sy, ei, from.ey, images.back());
                replacePixel(ei, from.sy, ei + car_size, from.ey, images.back(), cars[id]);
            }
        }
        else
        {
            int car_size = from.ex - from.sx;
            int movement_size = from.sx - to.sx;
            int movement = movement_size / moveSpeed;
            int start = from.sx;
            int end = to.sx;
            for (int i = start; i > end; i -= movement)
            {
                images.push_back(images.back());
                int tt = i + movement;
                int t1 = i - movement;
                resetPixel(t1 + car_size, from.sy, i + car_size, from.ey, images.back());
                replacePixel(t1, from.sy, t1 + car_size, from.ey, images.back(), cars[id]);
            }
        }
    }
}

void ImgGenerator::generate()
{
    init();
    renderMoves();
    createGif();
}
