cmake_minimum_required(VERSION 3.11)
project(SirinArcadeClient VERSION 0.1 DESCRIPTION "Sirin Arcades client application")


set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -g")


if(NOT SIRINARCADESDK_INCLUDE)
    message(FATAL_ERROR "Sirin Arcades SDK headers not found")
endif()

include_directories(${SIRINARCADESDK_INCLUDE})


set(SRC
    src/main.c
)


add_executable(${PROJECT_NAME} ${SRC})

target_link_directories(${PROJECT_NAME} PRIVATE ${SIRINARCADESDK_LIB_DIR})

target_link_libraries(${PROJECT_NAME} sound_player)
target_link_libraries(${PROJECT_NAME} tui_io)
target_link_libraries(${PROJECT_NAME} events_bus)
target_link_libraries(${PROJECT_NAME} resource_loader)
