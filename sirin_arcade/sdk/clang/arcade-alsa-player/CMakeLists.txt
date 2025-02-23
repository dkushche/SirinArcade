cmake_minimum_required(VERSION 3.11)
project(arcade_alsa_player VERSION 0.1 DESCRIPTION "")

set(CMAKE_C_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_library(ALSA_LIBRARY
    NAMES asound
    HINTS /usr/lib /usr/lib/alsa-lib /usr/local/lib
)
find_path(ALSA_INCLUDE_DIRS
    NAMES asoundlib.h
    HINTS /usr/include /usr/local/include
)

if(NOT ALSA_INCLUDE_DIRS OR NOT ALSA_LIBRARY)
    message(FATAL_ERROR "ALSA library or headers not found")
endif()

include_directories(${ALSA_INCLUDE_DIRS})


find_library(SNDFILE_LIBRARY
    NAMES sndfile
    PATHS /usr/lib /usr/local/lib
)
find_path(SNDFILE_INCLUDE_DIR
    NAMES sndfile.h
    PATHS /usr/include /usr/local/include

if (NOT SNDFILE_INCLUDE_DIR OR NOT SNDFILE_LIBRARY)
    message(FATAL_ERROR "SNDFILE library or headers not found")
endif()

include_directories(${SNDFILE_INCLUDE_DIR}))

set(SRC
    src/alsa-player.c
)

add_library(${PROJECT_NAME} SHARED ${SRC})


target_link_libraries(${PROJECT_NAME} m)
target_link_libraries(${PROJECT_NAME} ${ALSA_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${SNDFILE_LIBRARY})
