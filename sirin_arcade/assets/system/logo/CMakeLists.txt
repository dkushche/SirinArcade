cmake_minimum_required(VERSION 3.11)
project(SirinSystemLogo VERSION 0.1 DESCRIPTION "Sirin Arcade logo application")

set(DESTDIR_PATH "" CACHE STRING "Path to target system root")

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_FLAGS "-Wall -g")
# fPIC
include_directories(${SIRINARCADESDK_INCLUDE_DIRS})

set(SRC
    src/main.c
)

add_library(${PROJECT_NAME} SHARED ${SRC})
target_link_libraries(${PROJECT_NAME} ${SIRINARCADESDK_LIBRARIES})

target_include_directories(${PROJECT_NAME}
    PRIVATE ${CMAKE_INSTALL_INCLUDEDIR}/sirin_arcade
)

install(TARGETS ${PROJECT_NAME}
        LIBRARY DESTINATION ${DESTDIR_PATH}/usr/lib
)