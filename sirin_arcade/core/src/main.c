#include <stddef.h>
#include <stdlib.h>

#include <sirin_arcade/render.h>

//to remove
#include <alsa/asoundlib.h>
#include <math.h>
#include <sndfile.h>

#define BUFFER_SIZE 4096 * 2

int main(void)
{
    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        return 1;
    }

    pixel_t *pixel = create_pixel('X', ARCADE_YELLOW);

    // to move into lib
    snd_pcm_t *pcm_handle;
    snd_pcm_hw_params_t *params;
    int dir;

    snd_pcm_uframes_t frames = BUFFER_SIZE;

    // Відкриваємо пристрій
    if (snd_pcm_open(&pcm_handle, "hw:0,0", SND_PCM_STREAM_PLAYBACK, 0) < 0) {
        fprintf(stderr, "Cannot open audio device\n");
        exit(1);
    }

    //
    SF_INFO sfinfo;
    SNDFILE *sndfile = sf_open("/access_point/example.wav", SFM_READ, &sfinfo);
    if (!sndfile) {
        fprintf(stderr, "Не вдалося відкрити файл: %s\n", sf_strerror(NULL));
        return 1;
    }
    int channels = sfinfo.channels;
    unsigned int rate = (unsigned int) sfinfo.samplerate;
    short *buffer = malloc(BUFFER_SIZE * channels * sizeof(short)); // Буфер для зчитування аудіо

    // Встановлюємо параметри
    snd_pcm_hw_params_alloca(&params);

    snd_pcm_hw_params_any(pcm_handle, params);
    snd_pcm_hw_params_set_access(pcm_handle, params, SND_PCM_ACCESS_RW_INTERLEAVED);
    snd_pcm_hw_params_set_format(pcm_handle, params, SND_PCM_FORMAT_S16_LE);
    snd_pcm_hw_params_set_rate_near(pcm_handle, params, &rate, &dir);
    snd_pcm_hw_params_set_channels(pcm_handle, params, channels);  // 2 канали (стерео)
    snd_pcm_hw_params_set_period_size_near(pcm_handle, params, &frames, &dir);
    snd_pcm_hw_params(pcm_handle, params);
    if (snd_pcm_hw_params(pcm_handle, params) < 0) {
        fprintf(stderr, "Error setting HW params\n");
        exit(1);
    }
    // Відтворення звуку
    while (1) {
        int read_frames = sf_read_short(sndfile, buffer, frames * channels);

        // Якщо кінець файлу, зупиняємо відтворення
        if (read_frames == 0) {
            break;
        }

        // Відправляємо дані до пристрою
        int err = snd_pcm_writei(pcm_handle, buffer, read_frames / channels);
		if (err == -EPIPE) {
    		fprintf(stderr, "XRUN occurred\n");
    		snd_pcm_prepare(pcm_handle);
		} else if (err < 0) {
    		fprintf(stderr, "Error writing to PCM device: %s\n", snd_strerror(err));
    		break;
		}

    }
    sf_close(sndfile);
    snd_pcm_close(pcm_handle);



    //

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
