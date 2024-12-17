cmake_minimum_required(VERSION 3.10)  # Set the minimum required version of CMake
project(GIF_MAKER)                    

# Set the C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Set the root directory for resources (you can modify this path as needed)
set(RESOURCE_DIR "${CMAKE_SOURCE_DIR}/utils/data")

# Pass the resource directory to the compiler as a preprocessor definition
add_definitions(-DRESOURCE_DIR="${RESOURCE_DIR}")

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}      # Include current source directory
    ${CMAKE_SOURCE_DIR}/lib  # Include lib directory
)

# Source files
set(SRCS
    main.cpp
    utils/ImgGenerator.cc
    lib/stb_image.cc
    lib/stb_image_write.cc
)

# Header files (optional, for IDEs and documentation)
set(HEADERS
    utils/ImgGenerator.hh
    lib/stb_image.h
    lib/stb_image_write.h
)

# Add executable target
add_executable(main ${SRCS})
