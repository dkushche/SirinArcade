cmake_minimum_required(VERSION 3.11)
project(SirinarcadeSDK VERSION 0.1 DESCRIPTION "")

set(DESTDIR_PATH "" CACHE STRING "Path to target system root")
set(INCLUDE_SUBDIR "sirin_arcade" )
set(CMAKE_C_STANDARD 11)

find_package(Curses REQUIRED)
include_directories(${CURSES_INCLUDE_DIR})

include(GNUInstallDirs)

set(SRC
    src/render.c src/sound.c
)
add_library(${PROJECT_NAME} SHARED ${SRC})
target_link_libraries(${PROJECT_NAME} ${CURSES_LIBRARIES})

target_include_directories(
    ${PROJECT_NAME}
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/public> $<INSTALL_INTERFACE:include/${INCLUDE_SUBDIR}>
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
)

install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION ${DESTDIR_PATH}/usr/lib
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/public/
    DESTINATION ${DESTDIR_PATH}/usr/include/sirin_arcade
    FILES_MATCHING PATTERN "*"
)
