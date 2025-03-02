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

int draw(int32_t y_pos, int32_t x_pos, uint8_t color_pair_id, uint8_t character);
void render(void);

int tui_io_init(void);
void tui_io_deinit(void);

#endif // TUI_IO_H
