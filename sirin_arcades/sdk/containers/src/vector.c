#include <string.h>
#include <stdlib.h>
#include <vector.h>

static void vector_realloc(vector_t *self)
{
    self->capacity = self->capacity * 2;
    self->buffer = realloc(self->buffer, self->capacity);
}

static void vector_append(vector_t *self, void *element, size_t element_size)
{
    while (self->engaged + element_size >= self->capacity) {
        vector_realloc(self);
    }

    memcpy((char *)self->buffer + self->engaged, element, element_size);

    self->engaged += element_size;
}

static void vector_release(vector_t *self)
{
    self->engaged = 0;
}

vector_t *vector_init(void)
{
    vector_t *res = (vector_t *)malloc(sizeof(vector_t));

    res->capacity = 10;
    res->engaged = 0;

    res->buffer = malloc(res->capacity);

    res->append = vector_append;
    res->release = vector_release;

    return res;
}

void vector_deinit(vector_t *self)
{
    free(self->buffer);
    free(self);
}
