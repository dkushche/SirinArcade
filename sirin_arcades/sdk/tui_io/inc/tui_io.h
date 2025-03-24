#ifndef TUI_IO_H
#define TUI_IO_H

#include <stdint.h>

typedef enum {
    W = 'w',
    A = 'a',
    S = 's',
    D = 'd',
    SPACE = ' ',
    C = 'c',
    END = 0xFF,
} keys_t;

typedef struct screen {
    int32_t width;
    int32_t height;
} screen_t;

int set_pixel(int32_t y_pos, int32_t x_pos, uint8_t color_pair_id, uint8_t character);
void render(void);

screen_t *tui_io_init(void);
void tui_io_deinit(void);

char *get_keys(void);

#endif // TUI_IO_H
