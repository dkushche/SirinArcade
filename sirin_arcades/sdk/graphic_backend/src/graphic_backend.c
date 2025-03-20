#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <vector.h>
#include <stdint.h>
#include <graphic_backend.h>

static void clear_frame_buffer(double_buffered_frame_t *frame_buffer)
{
    pixel_t black_pixel = {.color_pair_id = ARCADE_BLACK, .character = ' '};

    for (int j = 0; j < frame_buffer->width * frame_buffer->height; j++)
    {
        frame_buffer->buffers[frame_buffer->active][j] = black_pixel;
    }
}

double_buffered_frame_t *generate_frame_buffers(int32_t width, int32_t height)
{
    if (width <= 0 || height <= 0)
    {
        return NULL;
    }

    double_buffered_frame_t *res =
        (double_buffered_frame_t *)malloc(sizeof(double_buffered_frame_t));

    res->width = width;
    res->height = height;

    for (int i = 0; i < 2; i++)
    {
        res->buffers[i] = (pixel_t *)malloc(width * height * sizeof(pixel_t));
        res->active = i;
        clear_frame_buffer(res);
    }

    return res;
}

void delete_frame_buffer(double_buffered_frame_t *frame_buffer)
{
    for (int i = 0; i < 2; i++)
    {
        free(frame_buffer->buffers[i]);
    }

    free(frame_buffer);
}

int set_frame_pixel(double_buffered_frame_t *frame_buffer,
                    int32_t x,
                    int32_t y,
                    uint8_t color_pair_id,
                    uint8_t character)
{
    if (x > frame_buffer->width || x < 0)
    {
        fprintf(stderr, "Draw out of screen boundaries\n");
        return 1;
    }

    if (x > frame_buffer->height || y < 0)
    {
        fprintf(stderr, "Draw out of screen boundaries\n");
        return 1;
    }

    pixel_t user_pixel = {.color_pair_id = color_pair_id, .character = character};

    frame_buffer->buffers[frame_buffer->active][y * frame_buffer->width + x] = user_pixel;

    return 0;
}

pixel_change_t *form_pixel_changes(double_buffered_frame_t *frame_buffer, size_t *changes_amount)
{
    int cur_buffer_id = frame_buffer->active;
    int prev_buffer_id = frame_buffer->active == 0 ? 1 : 0;

    vector_t *storage = vector_init();

    for (int i = 0; i < frame_buffer->height * frame_buffer->width; i++)
    {
        if (memcmp(frame_buffer->buffers[cur_buffer_id] + i,
                   frame_buffer->buffers[prev_buffer_id] + i,
                   sizeof(pixel_t)))
        {
            pixel_change_t change = {.x = i % frame_buffer->width,
                                     .y = i / frame_buffer->width,
                                     .pixel = frame_buffer->buffers[cur_buffer_id][i]};

            storage->append(storage, &change, sizeof(pixel_change_t));
        }
    }

    frame_buffer->active = prev_buffer_id;
    clear_frame_buffer(frame_buffer);

    *changes_amount = storage->engaged / (sizeof(pixel_change_t));

    pixel_change_t *res = (pixel_change_t *)malloc(storage->engaged);
    memcpy(res, storage->buffer, storage->engaged);

    vector_deinit(storage);

    return res;
}
