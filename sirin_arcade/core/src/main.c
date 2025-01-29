#include <stddef.h>
#include <stdlib.h>

#include <sirin_arcade/render.h>

int main(void)
{
    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        return 1;
    }

    pixel_t *pixel = create_pixel('X', ARCADE_YELLOW);

    while (1)
    {
        draw(screen, 0, 0, pixel);
        draw(screen, 0, screen->width - 1, pixel);
        draw(screen, screen->height - 1, 0, pixel);
        draw(screen, screen->height / 2, screen->width / 2, pixel);
        draw(screen, screen->height - 1, screen->width - 1, pixel);

        render(screen);
    }

    free(pixel);

    free_screen(screen);

    return 0;
}
