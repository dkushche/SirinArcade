#include <stddef.h>
#include <stdbool.h>
#include <stdlib.h>
#include <pthread.h>
#include <alsa/asoundlib.h>
#include <math.h>
#include <sndfile.h>
#include <time.h>
#include <stdio.h>
#include <stdatomic.h>
#include <sched.h>
#include <stdatomic.h>

#define BUFFER_SIZE 4096

typedef struct thread_arg {
    bool restart_on_end;
    atomic_bool stop_rn;
    char* path;

    short *buffer;
    snd_pcm_t *pcm_handle;
    SNDFILE *sndfile;
} thread_arg_t;

void free_resources(thread_arg_t *given_to_thread_data)
{
    free(given_to_thread_data->buffer);
    sf_close(given_to_thread_data->sndfile);
    snd_pcm_close(given_to_thread_data->pcm_handle);
    free(given_to_thread_data);
}

void *start_playing(void *arg)
{
    thread_arg_t *given_to_thread_data = (thread_arg_t *)arg;
    snd_pcm_t *pcm_handle;
    snd_pcm_uframes_t frames = BUFFER_SIZE;
    SF_INFO sfinfo;
    SNDFILE *sndfile;

    while (snd_pcm_open(&pcm_handle, "default", SND_PCM_STREAM_PLAYBACK, SND_PCM_ASYNC) < 0)
    {
        sched_yield();
    }

    given_to_thread_data->pcm_handle = pcm_handle;

    sndfile = sf_open(given_to_thread_data->path, SFM_READ, &sfinfo);
    if (!sndfile)
    {
        fprintf(stderr, "Failure with file opening\n");
        return NULL;
    }
    given_to_thread_data->sndfile = sndfile;

    int channels = sfinfo.channels;
    unsigned int rate = (unsigned int) sfinfo.samplerate;

    snd_pcm_hw_params_t *params;

    snd_pcm_hw_params_alloca(&params);
    if (snd_pcm_hw_params_any(pcm_handle, params) < 0)
    {
        fprintf(stderr, "Cannot initialize hardware parameters\n");
        return NULL;
    }
    if (snd_pcm_hw_params_set_access(pcm_handle, params, SND_PCM_ACCESS_RW_INTERLEAVED) < 0)
    {
        fprintf(stderr, "Error setting access type\n");
        return NULL;
    }
    if (snd_pcm_hw_params_set_format(pcm_handle, params, SND_PCM_FORMAT_S16_LE) < 0)
    {
        fprintf(stderr, "Error setting sample format\n");
        return NULL;
    }
    if (snd_pcm_hw_params_set_rate(pcm_handle, params, rate, 0) < 0)
    {
        fprintf(stderr, "Error setting sample rate\n");
        return NULL;
    }
    if (snd_pcm_hw_params_set_channels(pcm_handle, params, channels) < 0)
    {
        fprintf(stderr, "Error setting channel count\n");
        return NULL;
    }
    //  snd_pcm_hw_params_set_period_size_near(pcm_handle, params, &frames, &dir);

    //  fprintf(stderr, "Sample rate: %d, Channels: %d, Format: %d\n", sfinfo.samplerate, sfinfo.channels, sfinfo.format);

    if (snd_pcm_hw_params(pcm_handle, params) < 0)
    {
        fprintf(stderr, "Error setting HW params\n");
        return NULL;
    }

    short *buffer = malloc(BUFFER_SIZE * channels * sizeof(short));
    given_to_thread_data->buffer = buffer;

    while (true)
    {
        if (atomic_load(&given_to_thread_data->stop_rn) == true)
        {
            free_resources(given_to_thread_data);
            break;
        }

        int read_frames = sf_read_short(sndfile, buffer, frames * channels);

        if (read_frames == 0)
        {
            if (given_to_thread_data->restart_on_end == true)
            {
                free_resources(given_to_thread_data);
            }

            if (sf_seek(sndfile, 0, SEEK_SET) == -1)
            {
                fprintf(stderr, "setting audio to start failed \n");
                return NULL;
            }

            memset(buffer, 0, BUFFER_SIZE * channels * sizeof(short));

            snd_pcm_drop(pcm_handle);
            if (snd_pcm_prepare(pcm_handle) < 0)
            {
                fprintf(stderr, "snd_pcm_prepare failed\n");
                return NULL;
            }
        }

        for (int j = 0; j < read_frames / channels; j += 1)
        {
            int err = snd_pcm_writei(pcm_handle, buffer + j * channels, 1);
            if (err == -EPIPE)
            {
                fprintf(stderr, "XRUN occurred\n");
                snd_pcm_prepare(pcm_handle);
            }
            else if (err < 0)
            {
                fprintf(stderr, "Error writing to PCM device: %s\n", snd_strerror(err));
                break;
            }
        }
    }
}

int play_wave(char *path, bool cycled, void **sound)
{
    pthread_t thread;
    thread_arg_t *arg;

    *sound = NULL;
    arg = (thread_arg_t *)malloc(sizeof(thread_arg_t));
    if (arg == NULL)
    {
        fprintf(stderr, "Failed to allocate memory");
        return 1;
    }

    arg->restart_on_end = cycled;
    arg->path = path;
    arg->stop_rn = false;

    int result = pthread_create(&thread, NULL, start_playing, (void*)arg);

    if (result != 0)
    {
        fprintf(stderr, "Error creating thread: %d\n", result);
        return 2;
    }

    *sound = arg;

    return 0;
}

int free_wave(void **sound)
{
    if (sound == NULL)
    {
        fprintf(stderr, "error: you was saved from null pointer dereferencing in free_wave function");
        return 1;
    }

    if (*sound == NULL)
    {
        fprintf(stderr, "error: you was saved from null pointer dereferencing in free_wave function");
        return 2;
    }

    thread_arg_t *data = (thread_arg_t*)(*sound);

    atomic_store(&(data->stop_rn), true);

    *sound = NULL;
}
