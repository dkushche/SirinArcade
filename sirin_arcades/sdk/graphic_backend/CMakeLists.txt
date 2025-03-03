cmake_minimum_required(VERSION 3.11)
project(graphic_backend VERSION 0.1 DESCRIPTION "")

set(CMAKE_C_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include_directories(${SIRINARCADESDK_CONTAINERS_INCLUDE})

set(SRC
    src/graphic_backend.c
)

add_library(${PROJECT_NAME} SHARED ${SRC})

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/inc)

target_link_directories(${PROJECT_NAME} PRIVATE ${SIRINARCADESDK_CONTAINER_LIB_DIR})
target_link_libraries(${PROJECT_NAME} containers)
