cmake_minimum_required(VERSION 3.11)
project(arcade_alsa_player VERSION 0.1 DESCRIPTION "")

set(CMAKE_C_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(SRC
    src/alsa-player.c
)

add_library(${PROJECT_NAME} STATIC ${SRC})

