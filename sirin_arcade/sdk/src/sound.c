#include "private/sound.h"

#ifndef SOUND1_H
#define SOUND1_H

#include <stddef.h>
#include <stdlib.h>
#include <alsa/asoundlib.h>
#include <math.h>
#include <sndfile.h>
#include <time.h>
#include <stdio.h>
#include <stdatomic.h>
#include <sched.h>
#include <stdatomic.h>

#endif //SOUND1_H

#define BUFFER_SIZE 4096

typedef struct {
	int restart_on_end; // 1 yes, whatever else no
	atomic_bool stop_rn; // 1 yes
    char* path;
} thread_arg_t;

void start_playing(void *arg) {
	thread_arg_t *given_to_thread_data = (thread_arg_t *)arg;
    snd_pcm_t *pcm_handle;
    snd_pcm_uframes_t frames = BUFFER_SIZE;
    SF_INFO sfinfo;
    SNDFILE *sndfile;

    while (snd_pcm_open(&pcm_handle, "default", SND_PCM_STREAM_PLAYBACK, SND_PCM_ASYNC) < 0) {
        sched_yield();
    }

   	sndfile = sf_open(given_to_thread_data->path, SFM_READ, &sfinfo);
    if (!sndfile) {
        fprintf(stderr, "Failure with file opening\n");
        exit(1);
    }

    int channels = sfinfo.channels;
    unsigned int rate = (unsigned int) sfinfo.samplerate;

    snd_pcm_hw_params_t *params;

    snd_pcm_hw_params_alloca(&params);
    if (snd_pcm_hw_params_any(pcm_handle, params) < 0) {
    	fprintf(stderr, "Cannot initialize hardware parameters\n");
    	exit(1);
	}
	if (snd_pcm_hw_params_set_access(pcm_handle, params, SND_PCM_ACCESS_RW_INTERLEAVED) < 0) {
    	fprintf(stderr, "Error setting access type\n");
    	exit(1);
	}
	if (snd_pcm_hw_params_set_format(pcm_handle, params, SND_PCM_FORMAT_S16_LE) < 0) {
	    fprintf(stderr, "Error setting sample format\n");
    	exit(1);
	}
	if (snd_pcm_hw_params_set_rate(pcm_handle, params, rate, 0) < 0) {
    	fprintf(stderr, "Error setting sample rate\n");
    	exit(1);
	}
	if (snd_pcm_hw_params_set_channels(pcm_handle, params, channels) < 0) {
	    fprintf(stderr, "Error setting channel count\n");
	    exit(1);
	}
//    snd_pcm_hw_params_set_period_size_near(pcm_handle, params, &frames, &dir);

	printf("Sample rate: %d, Channels: %d, Format: %d\n", sfinfo.samplerate, sfinfo.channels, sfinfo.format);

    if (snd_pcm_hw_params(pcm_handle, params) < 0) {
        fprintf(stderr, "Error setting HW params\n");
        exit(1);
    }

    short *buffer = malloc(BUFFER_SIZE * channels * sizeof(short));

    while (1) {
      	if (atomic_load(&given_to_thread_data->stop_rn) == 1) {
			break;
      	}
        int read_frames = sf_read_short(sndfile, buffer, frames * channels);

        if (read_frames == 0) {
           	if (given_to_thread_data->restart_on_end != 1) {
                  break;
            }
            if (sf_seek(sndfile, 0, SEEK_SET) == -1) {
            	fprintf(stderr, "setting audio to start failed \n");
            	exit(1);
        	}

            memset(buffer, 0, BUFFER_SIZE * channels * sizeof(short));

            snd_pcm_drop(pcm_handle);
            if (snd_pcm_prepare(pcm_handle) < 0) {
            	fprintf(stderr, "snd_pcm_prepare failed\n");
            	exit(1);
            }
        }

        int err = snd_pcm_writei(pcm_handle, buffer, read_frames / channels);
		if (err == -EPIPE) {
    	    fprintf(stderr, "XRUN occurred\n");
    	    snd_pcm_prepare(pcm_handle);
        } else if (err < 0) {
   	    	fprintf(stderr, "Error writing to PCM device: %s\n", snd_strerror(err));
   	    	break; //or exit idk
	    }
    }

    free(buffer);
    sf_close(sndfile);
    free(arg);
    snd_pcm_close(pcm_handle);
}

void *play_wave(char *path, int cycled) {
	pthread_t thread;
    thread_arg_t *arg;

    arg = (thread_arg_t *)malloc(sizeof(thread_arg_t));
    if (arg == NULL) {
        perror("Failed to allocate memory");
        return NULL;
    }

    arg->restart_on_end = cycled;
    arg->path = path;
    arg->stop_rn = 0;

    int result = pthread_create(&thread, NULL, start_playing, (void*)arg);

	if (result != 0) {
        printf("Error creating thread: %d\n", result);
        return NULL;
    }

    if (cycled) {
      	return (void*)arg;
    } else {
     	return NULL;
    }
}

void stop_wave(void *sound) { // to call only once for cycled waves, or else... write after free
	atomic_store(&((thread_arg_t*)sound)->stop_rn, 1);
}