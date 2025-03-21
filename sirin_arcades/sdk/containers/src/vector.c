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
    while (self->engaged + element_size >= self->capacity)
    {
        vector_realloc(self);
    }

    memcpy((char *)self->buffer + self->engaged, element, element_size);

    self->engaged += element_size;
}

static void vector_release(vector_t *self)
{
    self->engaged = 0;
}

int vector_init(vector_t *self)
{
    if (self == NULL)
    {
        return -1;
    }
    self->capacity = 10;
    self->engaged = 0;

    self->buffer = malloc(self->capacity);

    self->append = vector_append;
    self->release = vector_release;

    return 0;
}

void vector_deinit(vector_t *self)
{
    free(self->buffer);
}
