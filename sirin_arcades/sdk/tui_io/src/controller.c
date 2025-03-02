#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <curses.h>

#include "public/tui_io.h"

char *global_array = NULL;
size_t global_array_capacity = 0;
size_t global_array_length = 0;

void add_to_array(char element) {
    if (global_array == NULL)
    {
        global_array_capacity = 10;

        global_array = (char *)malloc(
            global_array_capacity * sizeof(char)
        );
    }

    if (global_array_length == global_array_capacity)
    {
        global_array_capacity = global_array_capacity * 2;

        global_array = (char *)realloc(
            global_array, global_array_capacity * sizeof(char)
        );
    }

    global_array[global_array_length] = element;
    global_array_length = global_array_length + 1;
}

char *get_keys(void)
{
    global_array_length = 0;
    int ch;

    while ((ch = getch()) != EOF) {
        if (ch == W || ch == A || ch == S || ch == D || ch == SPACE || ch == C) {
            add_to_array(ch);
        }
    }

    add_to_array(END);

    return global_array;
}
