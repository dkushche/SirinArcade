#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <curses.h>

#include <tui_io.h>

typedef struct vector vector_t;

typedef void realloc_handler(vector_t *self);
typedef void add_handler(vector_t *self, char element, size_t *keys_array_length);

typedef struct vector
{
    char *keys_array;
    size_t capacity;

    realloc_handler *realloc;
    add_handler     *add;
} vector_t;

static void vector_add(vector_t *self, char element, size_t *keys_array_length)
{
    if (*keys_array_length == self->capacity)
    {
        self->realloc(self);
    }

    self->keys_array[*keys_array_length] = element;

    (*keys_array_length)++;
}

static void vector_realloc(vector_t *self)
{
    self->capacity = self->capacity * 2;

    self->keys_array = (char *)realloc(
        self->keys_array, self->capacity * sizeof(char)
    );
}

static vector_t *vector_init(void)
{
    vector_t *res = (vector_t *)malloc(sizeof(vector_t));

    res->capacity = 10;
    res->keys_array = (char *)malloc(
        res->capacity * sizeof(char)
    );

    res->realloc = vector_realloc;
    res->add = vector_add;

    return res;
}

char *get_keys(void)
{
    static vector_t *vec = NULL;

    size_t keys_array_length = 0;
    int ch;

    if (vec == NULL)
    {
        vec = vector_init();
    }

    while ((ch = getch()) != EOF) {
        if (ch == W || ch == A || ch == S || ch == D || ch == SPACE || ch == C) {
            vec->add(vec, ch, &keys_array_length);
        }
    }

    vec->add(vec, END, &keys_array_length);

    return vec->keys_array;
}
