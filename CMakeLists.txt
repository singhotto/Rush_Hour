cmake_minimum_required(VERSION 3.10)  # Set the minimum required version of CMake
project(RUSH_HOUR)                    

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Set the root directory for resources (you can modify this path as needed)
set(RESOURCE_DIR "${CMAKE_SOURCE_DIR}/gif_maker/data/")

# Pass the resource directory to the compiler as a preprocessor definition
add_definitions(-DRESOURCE_DIR="${RESOURCE_DIR}")

# Set the root directory for resources (you can modify this path as needed)
set(ROOT_DIR "${CMAKE_SOURCE_DIR}/build/")

# Pass the resource directory to the compiler as a preprocessor definition
add_definitions(-DROOT_DIR="${ROOT_DIR}")

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}      # Include current source directory
    ${CMAKE_SOURCE_DIR}/gif_maker/lib  # Include lib directory
)

# Source files
set(SRCS
    main.cpp
    resolver/Resolver.cc
    gif_maker/GifCreater.cc
    gif_maker/lib/stb_image.cc
    gif_maker/lib/stb_image_write.cc
)

# Header files (optional, for IDEs and documentation)
set(HEADERS
    resolver/Resolver.hh
    gif_maker/GifCreater.hh
    gif_maker/lib/stb_image.h
    gif_maker/lib/stb_image_write.h
)

# Add executable target
add_executable(main ${SRCS})
