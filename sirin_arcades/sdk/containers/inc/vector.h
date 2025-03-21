#ifndef VECTOR_H
#define VECTOR_H

#include <stddef.h>

typedef struct vector vector_t;

typedef void add_handler(vector_t *self, void *element, size_t element_size);
typedef void release_handler(vector_t *self);

typedef struct vector
{
    void *buffer;
    size_t engaged;
    size_t capacity;

    add_handler     *append;
    release_handler *release;
} vector_t;

int vector_init(vector_t *self);
void vector_deinit(vector_t *self);

#endif // VECTOR_H
