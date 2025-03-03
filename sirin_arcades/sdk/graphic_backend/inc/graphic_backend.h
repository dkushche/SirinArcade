#ifndef GRAPHIC_BACKEND
#define GRAPHIC_BACKEND

#include <stdbool.h>

typedef enum {
    ARCADE_BLACK =   0,
    ARCADE_RED =     1,
    ARCADE_GREEN =   2,
    ARCADE_YELLOW =  3,
    ARCADE_BLUE =    4,
    ARCADE_MAGENTA = 5,
    ARCADE_CYAN =    6,
    ARCADE_WHITE =   7
} ncurses_color_t;

typedef struct pixel
{
    uint8_t color_pair_id;
    uint8_t character;
} pixel_t;

typedef struct pixel_change
{
    int32_t x;
    int32_t y;
    pixel_t pixel;
} pixel_change_t;

typedef struct double_buffered_frame
{
    bool active;
    uint8_t width;
    uint8_t height;
    pixel_t *buffers[2];
} double_buffered_frame_t;

double_buffered_frame_t *generate_frame_buffer(int32_t width, int32_t height);
void delete_frame_buffer(double_buffered_frame_t *frame_buffer);

int set_frame_pixel(
    double_buffered_frame_t *frame_buffer,
    int32_t x, int32_t y,
    uint8_t color_pair_id, uint8_t character
);

pixel_change_t *form_pixel_changes(double_buffered_frame_t *frame_buffer, size_t *changes_amount);

#endif // GRAPHIC_BACKEND
