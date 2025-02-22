#ifndef ARCADE_ALSA_PLAYER_H
#define ARCADE_ALSA_PLAYER_H

#include <stdbool.h>

int play_wave(char *path, bool cycled, void **sound);
int free_wave(void **sound);

#endif // ARCADE_ALSE_PLAYER_H
