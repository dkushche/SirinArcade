cmake_minimum_required(VERSION 3.11)
project(resource_loader VERSION 0.1 DESCRIPTION "Library that helps resource loader using alsa")

set(CMAKE_C_STANDARD 11)

find_package(CURL REQUIRED)
include_directories(${CURL_INCLUDE_DIRS})

set(SRC
    src/resource_loader.c
)

add_library(${PROJECT_NAME} SHARED ${SRC})

target_link_libraries(${PROJECT_NAME} ${CURL_LIBRARIES})
