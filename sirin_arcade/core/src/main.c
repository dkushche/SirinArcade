#include <stddef.h>
#include <stdlib.h>

#include <sirin_arcade/render.h>
#include <sirin_arcade/sound.h>

//to remove
#include <alsa/asoundlib.h>
#include <math.h>
#include <sndfile.h>
#include <time.h>
#include <stdio.h>
#include <stdatomic.h>
#include <sched.h>

/**
* ~/.asoundrc

pcm.!default {
	type plug
	slave.pcm "dmixer"
}

pcm.dmixer  {
 	type dmix
 	ipc_key 1024
	slave.pcm "hw:0,0"
}

ctl.dmixer {
	type hw
	card 0
}
*/

int main(void)
{
    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        return 1;
    }

    pixel_t *pixel = create_pixel('X', ARCADE_YELLOW);

	void *haha;
    int result = play_wave("/access_point/example.wav", 1, &haha);
    if (result != 0) {
      	printf("got error from play_wave\n");
        exit(1);
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

	free_wav(&haha);
    free(pixel);

    free_screen(screen);
    return 0;
}
