#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <curses.h>

#include <tui_io.h>

static char *keys_array = NULL;
static size_t keys_array_capacity = 0;
static size_t keys_array_length = 0;

void add_to_array(char element) {
    if (keys_array == NULL)
    {
        keys_array_capacity = 10;

        keys_array = (char *)malloc(
            keys_array_capacity * sizeof(char)
        );
    }

    if (keys_array_length == keys_array_capacity)
    {
        keys_array_capacity = keys_array_capacity * 2;

        keys_array = (char *)realloc(
            keys_array, keys_array_capacity * sizeof(char)
        );
    }

    keys_array[keys_array_length] = element;
    keys_array_length = keys_array_length + 1;
}

char *get_keys(void)
{
    keys_array_length = 0;
    int ch;

    while ((ch = getch()) != EOF) {
        if (ch == W || ch == A || ch == S || ch == D || ch == SPACE || ch == C) {
            add_to_array(ch);
        }
    }

    add_to_array(END);

    return keys_array;
}
