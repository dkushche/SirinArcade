#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include <sirin_arcade/render.h>
#include <sirin_arcade/sound.h>

int main(void)
{
    int res = 0;

    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        res = 1;
        goto end;
    }

    pixel_t *pixel = create_pixel('X', ARCADE_YELLOW);

    void *haha;
    int result = play_wave("/sirin_arcade/core/assets/intro.wav", true, &haha);
    if (result != 0)
    {
        fprintf(stderr, "Got error from play_wave\n");
        res = 2;
        goto audio_err;
    }

    while (1)
    {
        draw(screen, 0, 0, pixel);
        draw(screen, 0, screen->width - 1, pixel);
        draw(screen, screen->height - 1, 0, pixel);
        draw(screen, screen->height / 2, screen->width / 2, pixel);
        draw(screen, screen->height - 1, screen->width - 1, pixel);

        render(screen);
    }

    free_wave(&haha);
    free(pixel);

audio_err:
    free_screen(screen);

end:
    return res;
}
