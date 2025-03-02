
typedef struct pixel
{
    uint8_t color_pair_id;
    uint8_t character;
} pixel_t;

typedef struct double_buffered_frame
{
    uint8_t width;
    uint8_t height;
    pixel_t *buffers[2];
} double_buffered_frame_t;

double_buffered_frame_t *generate_frame_buffers(int32_t width, int32_t height)
{
    if (width <= 0 || height <= 0)
    {
        return NULL;
    }

    double_buffered_frame_t *res = (double_buffered_frame_t *)malloc(
        sizeof(double_buffered_frame_t)
    );

    res->width = width;
    res->height = height;

    for (int i = 0; i < 2; i++)
    {
        res->buffers[i] = (pixel_t *)malloc()
    }
}








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

            
        }

        screen->buffers[prev_buffer_id][j].character = ' ';
    }

    screen->active_buffer = prev_buffer_id;    
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

