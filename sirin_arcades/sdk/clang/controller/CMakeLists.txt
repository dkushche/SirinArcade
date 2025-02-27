cmake_minimum_required(VERSION 3.11)
project(controller VERSION 0.1 DESCRIPTION "Library that helps play audio using alsa")

set(CMAKE_C_STANDARD 11)

find_package(Curses REQUIRED)
include_directories(${CURSES_INCLUDE_DIR})

set(SRC
    src/controller.c
)

add_library(${PROJECT_NAME} SHARED ${SRC})

target_link_libraries(${PROJECT_NAME} ${CURSES_LIBRARIES})
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/inc)
