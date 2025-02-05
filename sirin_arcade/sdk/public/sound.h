#ifndef SOUND_H
#define SOUND_H

#include <stdbool.h>

int play_wave(char *path, bool cycled, void **sound);
int free_wave(void **sound);

#endif //SOUND_H
