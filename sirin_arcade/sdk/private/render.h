#ifndef RENDER_H
#define RENDER_H

#include <stdint.h>

typedef enum {
    ARCADE_BLACK = 0,
    ARCADE_RED,
    ARCADE_GREEN,
    ARCADE_YELLOW,
    ARCADE_BLUE,
    ARCADE_MAGENTA,
    ARCADE_CYAN,
    ARCADE_WHITE
} ncurses_color_t;

typedef struct pixel {
    char character;
    uint8_t color_pair_id;
} pixel_t;

typedef struct screen {
    uint8_t width;
    uint8_t height;

    uint8_t active_buffer;
    pixel_t *buffers[2];
} screen_t;

#endif // RENDER_H
