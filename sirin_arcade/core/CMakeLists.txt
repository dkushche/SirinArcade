cmake_minimum_required(VERSION 3.11)
project(SirinArcade VERSION 0.1 DESCRIPTION "Sirin Arcade core application")

set(DESTDIR_PATH "" CACHE STRING "Path to target system root")

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -g")

find_package(Curses REQUIRED)
include_directories(${CURSES_INCLUDE_DIR})

include_directories(${SIRINARCADESDK_INCLUDE_DIRS})

find_path(ALSA_INCLUDE_DIRS
        NAMES asoundlib.h
        HINTS /usr/include /usr/local/include
)

find_library(ALSA_LIBRARIES
        NAMES asound
        HINTS /usr/lib /usr/lib/alsa-lib /usr/local/lib
)

find_library(SNDFILE_LIBRARY NAMES sndfile PATHS /usr/lib /usr/local/lib)
find_path(SNDFILE_INCLUDE_DIR NAMES sndfile.h PATHS /usr/include /usr/local/include)

if(NOT ALSA_INCLUDE_DIRS OR NOT ALSA_LIBRARIES)
    message(FATAL_ERROR "ALSA library or headers not found")
endif()

if (SNDFILE_INCLUDE_DIR)
    include_directories(${SNDFILE_INCLUDE_DIR})
else()
    message(FATAL_ERROR "Не вдалося знайти бібліотеку sndfile!")
endif()

include_directories(${ALSA_INCLUDE_DIRS})

set(SRC
    src/main.c
)

add_executable(${PROJECT_NAME} ${SRC})
target_link_libraries(${PROJECT_NAME} ${CURSES_LIBRARIES} ${SIRINARCADESDK_LIBRARIES})
target_link_libraries(${PROJECT_NAME} m ${ALSA_LIBRARIES})

if (SNDFILE_LIBRARY)
    target_link_libraries(${PROJECT_NAME} ${SNDFILE_LIBRARY})
else()
    message(FATAL_ERROR "sndfile was not found")
endif()


target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_INSTALL_INCLUDEDIR}/sirin_arcade
)

install(
    TARGETS ${PROJECT_NAME} DESTINATION ${DESTDIR_PATH}/bin
)
