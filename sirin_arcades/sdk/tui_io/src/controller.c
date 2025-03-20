#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <curses.h>

#include <vector.h>
#include <tui_io.h>

char *get_keys(void)
{
    static vector_t *vec = NULL;

    size_t keys_array_length = 0;
    int ch;

    if (vec == NULL)
    {
        vec = vector_init();
    }

    while ((ch = getch()) != EOF)
    {
        if (ch == W || ch == A || ch == S || ch == D || ch == SPACE || ch == C)
        {
            vec->append(vec, &ch, sizeof(char));
        }
    }

    ch = END;

    vec->append(vec, &ch, sizeof(char));
    vec->release(vec);

    return vec->buffer;
}
