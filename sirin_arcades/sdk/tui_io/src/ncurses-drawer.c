#include <ncurses.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

typedef struct screen {
    int32_t width;
    int32_t height;
} screen_t;

static screen_t screen = {0, 0};

int draw(int32_t y_pos, int32_t x_pos, uint8_t color_pair_id, uint8_t character)
{
    if (x_pos >= screen.width)
    {
        fprintf(stderr, "Draw out of screen boundaries\n");
        return 1;
    }

    if (y_pos >= screen.height)
    {
        fprintf(stderr, "Draw out of screen boundaries\n");
        return 1;
    }

    attron(COLOR_PAIR(color_pair_id));
    mvaddch(y_pos, x_pos, character);
    attroff(COLOR_PAIR(color_pair_id));

    return 0;
}

void render(void)
{
    refresh();
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

    init_pair(0, COLOR_BLACK, COLOR_BLACK);
    init_pair(1, COLOR_RED, COLOR_BLACK);
    init_pair(2, COLOR_GREEN, COLOR_BLACK);
    init_pair(3, COLOR_YELLOW, COLOR_BLACK);
    init_pair(4, COLOR_BLUE, COLOR_BLACK);
    init_pair(5, COLOR_MAGENTA, COLOR_BLACK);
    init_pair(6, COLOR_CYAN, COLOR_BLACK);
    init_pair(7, COLOR_WHITE, COLOR_BLACK);

    return 0;
}

int tui_io_init(void)
{
    initscr();
    nodelay(stdscr, TRUE);
    clear();
    _disable_redundant_term_func();

    if (_init_colors() != 0)
    {
        goto err;
    }

    keypad(stdscr, TRUE);

    getmaxyx(stdscr, screen.height, screen.width);

    return 0;

err:
    endwin();
    return -1;
}

void tui_io_deinit(void)
{
    endwin();
}
