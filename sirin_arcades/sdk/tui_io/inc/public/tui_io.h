#ifndef TUI_IO_H
#define TUI_IO_H

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

typedef enum {
    W = 'w',
    A = 'a',
    S = 's',
    D = 'd',
    SPACE = ' ',
    C = 'c',
    END = 0xFF,
} keys_t;

typedef struct pixel pixel_t;

typedef struct screen {
    uint8_t width;
    uint8_t height;
} screen_t;

pixel_t *create_pixel(char character, uint8_t color_pair_id);
char *get_keys(void);

void fill_screen_with_pixel(screen_t *screen, pixel_t *pixel);
int draw(screen_t *screen, uint8_t y_pos, uint8_t x_pos, pixel_t *pixel);

screen_t *initialze_screen(void);
int free_screen(screen_t *screen);

void render(screen_t *screen);

#endif // TUI_IO_H
