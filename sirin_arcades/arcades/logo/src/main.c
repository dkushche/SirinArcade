#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#include <vector.h>
#include <events_bus.h>

char logo[][96] = {
#include "logo.txt"
};
const size_t logo_width = sizeof(logo[0]);
const size_t logo_height = sizeof(logo) / logo_width;
#define RANDOM_COLOR_PAIR 3
#define NORMAL_COLOR_PAIR 0

void add_logo(vector_t *vec)
{
    for (size_t y = 0; y < logo_height; y++)
    {
        const char *line = logo[y];
        for (size_t x = 0; line[x] != '\0'; x++)
        {
            if (line[x] != ' ')
            {
                SoToServerTransitBack event_to_client = {
                    .tag = ToClient,
                    .to_client = {.tag = DrawPixel,
                                  .draw_pixel = {.x = x,
                                                 .y = y,
                                                 .pixel_t = {.character = (uint8_t)line[x],
                                                             .color_pair_id = NORMAL_COLOR_PAIR}}}};
                vec->append(vec, &event_to_client, sizeof(SoToServerTransitBack));
            }
        }
    }
}

static bool is_special_char(const char c)
{
    return c == '-' || c == '=' || c == '+' || c == '#' || c == '@' || c == '*' || c == '%';
}

int gcd(int a, int b)
{
    int temp;

    while (b != 0)
    {
        temp = a % b;

        a = b;
        b = temp;
    }
    return a;
}

int find_random_k(int n)
{
    srand(time(NULL));
    int k;
    do
    {
        k = rand() % n;
    } while (k == 0 || gcd(k, n) != 1);
    return k;
}

int get_next_victim()
{
    static int gcd_place = -1;
    if (gcd_place == -1)
    {
        gcd_place = find_random_k(logo_height * logo_width);
        if (gcd_place == -1)
        {
            //
            exit(0);
        }
    }
    static int x = 0;
    static int starting_num = 0; // value must be the same as in x variable

    int result = x;
    x = (x + gcd_place) % (logo_height * logo_width);
    if (x == starting_num)
    {
        return -1;
    }

    return result;
}

static void add_random_logo_pixels_changes(vector_t *vec, size_t count, int *iteration)
{
    for (size_t i = 0; i < count; i++)
    {
        size_t y, x;
        char ch;

        int victim = get_next_victim();
        if (victim == -1)
        {
            *iteration = -1;
            return;
        }
        y = victim / logo_width;
        x = victim % logo_width;
        ch = logo[y][x];
        if (!is_special_char(ch))
        {
            i--;
            continue;
        }

        SoToServerTransitBack event_to_client = {
            .tag = ToClient,
            .to_client = {
                .tag = DrawPixel,
                .draw_pixel = {.x = x,
                               .y = y,
                               .pixel_t = {.character = ch, .color_pair_id = RANDOM_COLOR_PAIR}}}};
        vec->append(vec, &event_to_client, sizeof(SoToServerTransitBack));
    }
}

SoToServerTransitBackArray game_frame(ServerToSoTransitEvent *first_event, size_t length)
{
    static vector_t vec = {.buffer = NULL, .engaged = 0, .capacity = 0};
    static int iteration = 0;

    if (vec.buffer == NULL)
    {
        int result = vector_init(&vec);
        if (result != NULL) {
            printf("vector init error: %d", result);
            exit(0);
        }
    }
    vec.release(&vec);

    if (iteration == 0)
    {
        add_logo(&vec);
	    SoToServerTransitBack event_end = {
            .tag = ToClient,
            .to_client = {.tag = PlayResource}};
		snprintf(event_end.to_client.play_resource.data, sizeof(event_end.to_client.play_resource.data), "intro.wav");
        vec.append(&vec, &event_end, sizeof(SoToServerTransitBack));
    }
    else
    {
        add_random_logo_pixels_changes(&vec, 30, &iteration);
        if (iteration == -1)
        {
            SoToServerTransitBack event_end = {
                .tag = ToServer,
                .to_server = {.tag = GoToState, .go_to_state = Menu}};
            vec.append(&vec, &event_end, sizeof(SoToServerTransitBack));
        }
    }

    SoToServerTransitBackArray array = {
        .first_element = vec.buffer,
        .length = vec.engaged / sizeof(SoToServerTransitBack),
    };

    iteration++;
    return array;
}
