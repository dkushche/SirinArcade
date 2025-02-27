#include <ncurses.h>
#include <string.h>
#include <stdlib.h>

#include "private/terminal-drawer.h"


pixel_t *create_pixel(char character, uint8_t color_pair_id)
{
    pixel_t *new_pixel = (pixel_t *)malloc(sizeof(pixel_t));

    new_pixel->character = character;
    new_pixel->color_pair_id = color_pair_id;

    return new_pixel;
}

void fill_screen_with_pixel(screen_t *screen, pixel_t *pixel)
{
    for (uint16_t i = 0; i < screen->height * screen->width; i++)
    {
        screen->buffers[screen->active_buffer][i] = *pixel;
    }
}

int draw(screen_t *screen, uint8_t y_pos, uint8_t x_pos, pixel_t *pixel)
{
    if (x_pos >= screen->width)
    {
        fprintf(stderr, "Draw out of screen boundaries\n");
        return 1;
    }

    if (y_pos >= screen->height)
    {
        fprintf(stderr, "Draw out of screen boundaries\n");
        return 1;
    }

    size_t buffer_pos = y_pos * screen->width + x_pos;

    screen->buffers[screen->active_buffer][buffer_pos] = *pixel;

    return 0;
}

void render(screen_t *screen)
{
    int cur_buffer_id = screen->active_buffer;
    int prev_buffer_id = screen->active_buffer == 0 ? 1 : 0;

    for (uint16_t j = 0; j < screen->height * screen->width; j++)
    {
        if (memcmp(&screen->buffers[cur_buffer_id][j], &screen->buffers[prev_buffer_id][j], sizeof(pixel_t)) != 0)
        {
            uint8_t x_pos = j % screen->width;
            uint8_t y_pos = j / screen->width;

            attron(COLOR_PAIR(screen->buffers[cur_buffer_id][j].color_pair_id));
            mvaddch(y_pos, x_pos, screen->buffers[cur_buffer_id][j].character);
            attroff(COLOR_PAIR(screen->buffers[cur_buffer_id][j].color_pair_id));
        }

        screen->buffers[prev_buffer_id][j].character = ' ';
    }

    screen->active_buffer = prev_buffer_id;

    refresh();
}

static void _initialize_buffers(screen_t *screen)
{
    pixel_t *black_pixel = create_pixel(' ', ARCADE_BLACK);

    for (int i = 0; i < 2; i++)
    {
        size_t buffer_size = screen->height * screen->width * sizeof(pixel_t);

        screen->buffers[i] = (pixel_t *)malloc(buffer_size);

        screen->active_buffer = i;
        fill_screen_with_pixel(screen, black_pixel);
    }

    free(black_pixel);

    screen->active_buffer = 0;
}

static void _free_buffers(screen_t *screen)
{
    for (int i = 0; i < 2; i++) {
        free(screen->buffers[i]);
    }
}

static void _disable_redundant_term_func()
{
    nonl();
    cbreak();
    noecho();

    curs_set(FALSE);
}

static int _init_colors()
{
    if(has_colors() == FALSE)
    {
        fprintf(stderr, "Your terminal does not support color\n");
        return -1;
    }

    start_color();

    init_pair(ARCADE_BLACK, COLOR_BLACK, COLOR_BLACK);
    init_pair(ARCADE_RED, COLOR_RED, COLOR_BLACK);
    init_pair(ARCADE_GREEN, COLOR_GREEN, COLOR_BLACK);
    init_pair(ARCADE_YELLOW, COLOR_YELLOW, COLOR_BLACK);
    init_pair(ARCADE_BLUE, COLOR_BLUE, COLOR_BLACK);
    init_pair(ARCADE_MAGENTA, COLOR_MAGENTA, COLOR_BLACK);
    init_pair(ARCADE_CYAN, COLOR_CYAN, COLOR_BLACK);
    init_pair(ARCADE_WHITE, COLOR_WHITE, COLOR_BLACK);

    return 0;
}

screen_t *initialze_screen(void)
{
    screen_t *screen = (screen_t *)malloc(sizeof(screen_t));

    if (screen == NULL)
    {
        fprintf(stderr, "Error allocating screen entity\n");
        return NULL;
    }

    initscr();
    nodelay(stdscr, TRUE);
    clear();
    _disable_redundant_term_func();

    if (_init_colors() != 0)
    {
        goto err;
    }

    keypad(stdscr, TRUE);

    getmaxyx(stdscr, screen->height, screen->width);
    _initialize_buffers(screen);

    return screen;

err:
    endwin();
    return NULL;
}

int free_screen(screen_t *screen)
{
    if (screen == NULL)
    {
        return -1;
    }

    _free_buffers(screen);
    free(screen);

    endwin();

    return 0;
}
