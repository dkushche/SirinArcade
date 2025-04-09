#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>
#include <string.h>

#include <vector.h>
#include <events_bus.h>

typedef struct game_internal {
	char *so_path;
    char *name;
    char *resources_path;
} game_internal_t;

const char ARCADE_RESOURCES_PATH[] = "/etc/sirin_arcades/arcades_resources/";

SoToServerTransitBackArray game_frame(ServerToSoTransitEvent *first_event, size_t length)
{
    fprintf(stderr, "so starting handling events\n");

    static vector_t vec = {.buffer = NULL, .engaged = 0, .capacity = 0};
    static int iteration = 0;

    if (vec.buffer == NULL)
    {
        int result = vector_init(&vec);
        if (result != NULL) {
            fprintf(stderr, "vector init error: %d\n", result);
            exit(0);
        }
    }
    vec.release(&vec);

    if (iteration == 0)
    {
        // запрінтити назви сошок обрізані крім системних
        struct dirent *entry;
        DIR *dp;

        dp = opendir("/sirin_arcades/out/etc/sirin_arcades/arcades"); //todo
        if (dp == NULL) {
            fprintf(stderr, "opend\n");
        }

        while ((entry = readdir(dp)) != NULL) {
            if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0
                || strcmp(entry->d_name, "liblobby_arcade.so") == 0 || strcmp(entry->d_name, "liblogo_arcade.so") == 0 || strcmp(entry->d_name, "libmenu_arcade.so") == 0) {
                continue;
            }

            // todo check lib*_arcade.so?
            int name_len = strlen(entry->d_name) - 13;

            game_internal_t game = {
                .so_path = malloc(strlen(entry->d_name) + 1),
                .name = malloc(name_len + 1),
                .resources_path = malloc(name_len + sizeof(ARCADE_RESOURCES_PATH)),// /etc/sirin_arcades/arcades_resources/ + name
            };

//          if (game.so_path == NULL) { // etc etc
//        		exit(0);
//    		}
			strcpy(game.so_path, entry->d_name);

            memcpy(game.name, entry->d_name + 3, name_len);
            game.name[name_len] = '\0';

            strcpy(game.resources_path, ARCADE_RESOURCES_PATH);
            strcpy(game.resources_path + sizeof(ARCADE_RESOURCES_PATH) - 1, game.name);

            fprintf(stderr, "sopath %s\nname %s\nresources_path %s\n", game.so_path, game.name, game.resources_path);
            // game {
            //  so_path: libpong_arcade.so,
            //  name: pong
            //  resources_path: /etc/sirin_arcades/arcades_resources/pong
            // }

            //free everything in game
        }

        closedir(dp);
    }
    else
    {
        if (iteration == -1)
        {
//            SoToServerTransitBack event_end = {
//                .tag = ToServer,
//                .to_server = {.tag = GoToState, .go_to_state = Menu}};
//            vec.append(&vec, &event_end, sizeof(SoToServerTransitBack));
        }
    }

    SoToServerTransitBackArray array = {
        .first_element = vec.buffer,
        .length = vec.engaged / sizeof(SoToServerTransitBack),
    };

    fprintf(stderr, "so finished handling events\n");

    iteration++;
    return array;
}
