cmake_minimum_required(VERSION 3.11)
project(menu_arcade VERSION 0.1 DESCRIPTION "Sirin Arcades Menu Arcade")


set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -g")


if(NOT SIRINARCADESDK_INCLUDE)
    message(FATAL_ERROR "Sirin Arcades SDK headers not found")
endif()

include_directories(${SIRINARCADESDK_INCLUDE})


set(SRC
    src/main.c
)


add_library(${PROJECT_NAME} SHARED ${SRC})

target_link_directories(${PROJECT_NAME} PRIVATE ${SIRINARCADESDK_LIB_DIR})

target_link_libraries(${PROJECT_NAME} sound_player)
target_link_libraries(${PROJECT_NAME} terminal_drawer)
target_link_libraries(${PROJECT_NAME} events_bus)
