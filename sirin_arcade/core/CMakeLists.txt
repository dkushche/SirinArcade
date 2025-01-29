cmake_minimum_required(VERSION 3.11)
project(SirinArcade VERSION 0.1 DESCRIPTION "Sirin Arcade core application")

set(DESTDIR_PATH "" CACHE STRING "Path to target system root")

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -g")

find_package(Curses REQUIRED)
include_directories(${CURSES_INCLUDE_DIR})

include_directories(${SIRINARCADESDK_INCLUDE_DIRS})

set(SRC
    src/main.c
)

add_executable(${PROJECT_NAME} ${SRC})
target_link_libraries(${PROJECT_NAME} ${CURSES_LIBRARIES} ${SIRINARCADESDK_LIBRARIES})

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_INSTALL_INCLUDEDIR}/sirin_arcade
)

install(
    TARGETS ${PROJECT_NAME} DESTINATION ${DESTDIR_PATH}/bin
)
