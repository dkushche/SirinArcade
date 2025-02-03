#include <stddef.h>
#include <stdlib.h>

#include <sirin_arcade/render.h>

//to remove
#include <alsa/asoundlib.h>
#include <math.h>
#include <sndfile.h>
#include <time.h>
#include <stdio.h>

#define BUFFER_SIZE 4096

typedef struct {
    snd_pcm_t *pcm_handle;
} thread_arg_t;

void* hell(void *arg) {
	thread_arg_t *data = (thread_arg_t *)arg;

    snd_pcm_t *pcm_handle = data->pcm_handle;
    snd_pcm_hw_params_t *params;
    int dir;

    snd_pcm_uframes_t frames = BUFFER_SIZE;

    //
    SF_INFO sfinfo;
    SNDFILE *sndfile = sf_open("/access_point/example.wav", SFM_READ, &sfinfo);
    if (!sndfile) {
        fprintf(stderr, "Не вдалося відкрити файл: %s\n", sf_strerror(NULL));
        exit(1);
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
    clock_t start_time;
    start_time = clock();

    // Відтворення звуку
    while (1) {
        double time_taken = (((double)(clock() - start_time))/CLOCKS_PER_SEC); // in seconds
        if (time_taken >= 10.0) {
            start_time = clock();
            if (sf_seek(sndfile, 0, SEEK_SET) == -1) {
              fprintf(stderr, "setting audio to start failed \n");
              exit(0);
            }
            memset(buffer, 0, BUFFER_SIZE * channels * sizeof(short));
            snd_pcm_drop(pcm_handle); // Зупиняємо відтворення
            int err = snd_pcm_prepare(pcm_handle); // Готуємо пристрій знову
			if (err < 0) {
            	fprintf(stderr, "wtf, prepare failed: %s\n", snd_strerror(err));
            	exit(0);
            }
        }
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
    free(buffer);
    sf_close(sndfile);
    free(arg);
	return NULL;
}

int main(void)
{
    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        return 1;
    }

    pixel_t *pixel = create_pixel('X', ARCADE_YELLOW);

    // to move into lib


    // Відкриваємо пристрій
    snd_pcm_t *pcm_handle;
    while (snd_pcm_open(&pcm_handle, "hw:0,0", SND_PCM_STREAM_PLAYBACK, 0) < 0) {
        fprintf(stderr, "Trying open audio device again\n");
    }

    pthread_t *thread;
    thread_arg_t *arg = (thread_arg_t *)malloc(sizeof(thread_arg_t));
    if (arg == NULL) {
        perror("Failed to allocate memory");
        return 1;
    }
    arg->pcm_handle = pcm_handle;
    int result = pthread_create(thread, NULL, hell, (void*)arg);
    //do not reuse arg, its now for that thread and not anyone else!

	if (result != 0) {
        // Перевірка на помилку
        printf("Error creating thread: %d\n", result);
        return 1;
    }
    sleep(5);

    thread_arg_t *arg2 = (thread_arg_t *)malloc(sizeof(thread_arg_t));
    if (arg2 == NULL) {
        perror("Failed to allocate memory");
        return 1;
    }
    arg2->pcm_handle = pcm_handle;
    pthread_t *thread2;

    pthread_create(thread2, NULL, hell, (void*)arg2);
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

    snd_pcm_close(pcm_handle);

    return 0;
}
