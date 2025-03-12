#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

#include <events_bus.h>

SoToServerTransitBack *global_array = NULL;
size_t global_array_capacity = 0;
size_t global_array_length = 0;

void add_to_array(SoToServerTransitBack *element) {
    if (global_array == NULL)
    {
        global_array_capacity = 10;

        global_array = (SoToServerTransitBack *)malloc(
            global_array_capacity * sizeof(SoToServerTransitBack)
        );
    }

    if (global_array_length == global_array_capacity)
    {
        global_array_capacity = global_array_capacity * 2;

        global_array = (SoToServerTransitBack *)realloc(
            global_array, global_array_capacity * sizeof(SoToServerTransitBack)
        );
    }

    global_array[global_array_length] = *element;
    global_array_length = global_array_length + 1;
}

//    #include <file.txt> todo
char logo[][96] = {
    "                          ++                                                                   ",
    "                         +#                                                                    ",
    "                         *%                                                                    ",
    "                         %@+                                                                   ",
    "                         %@%                                                                   ",
    "                         *@@@+                                                                 ",
    "                         +@@@@@@***++                                                          ",
    "                          *@@@@@@@@@@@@@@@@@###+                                               ",
    "                           *@@@@@@@@@@@@@@@@@@@@@@@@##=-                                       ",
    "                            #@@@@@@@@@@@@@@@@@@@@@@@@@@@%#                                     ",
    "                               *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%*                                ",
    "@@@@@@@@@@%%%%#+                  +#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                             ",
    "@@@@@@@@@@@@@@@@@@@@@@@%#=-          -=++#@@@@@@@@@@@@@@@@@@@@@@@@@#                           ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*            +=#@@@@@@@@@@@@@@@@@@@@@#                         ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+-     -=====%@@@@@@@@@@@@@@@@@@                        ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*-      -==@@@@@@@@@@@@@@@@#                     ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=--     @@@@@@@@@@@@@@#                    ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+- =-@@@@@@@@@@@@@+                   ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@*=-                 ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#=-                ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%                ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#              ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*            ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%           ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*         ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+      ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%###*+              =+*##@@@@@@@@@@@@+      ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%**+                                =+#@@@@@@@@*    ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%#*+                                            =*%@@@@+    ",
    "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#*+                                                      =+%@@+   ",
    "@@@@@@@@@@@@@@@@@@@@@@@@%*                                                                =+@=-",
    "@@@@@@@@@@@@@@@@@@@*                                                                           ",
    "@@@@@@@@@@@@@@@*                                                                               ",
    "@@@@@@@@@@*                                                                                    ",
    "@@@@@@+                                                                                        ",
    "@@%                                                                                            ",
    "-                                                                                              "
};
const size_t logo_width = sizeof(logo[0]);
const size_t logo_height = sizeof(logo)/logo_width;
#define RANDOM_COLOR_PAIR 3
#define NORMAL_COLOR_PAIR 0

void add_logo() {
    for (size_t y = 0; y < logo_height; y++) {
        const char *line = logo[y];
        for (size_t x = 0; line[x] != '\0'; x++) {
            if (line[x] != ' ') {
                SoToServerTransitBack event_to_client = {
                    .tag = ToClient,
                    .to_client = {
                        .tag = DrawPixel,
                        .draw_pixel = {
                            .x = x,
                    	    .y = y,
                        	.pixel_t = {
                            	.character = (uint8_t)line[x],
                            	.color_pair_id = NORMAL_COLOR_PAIR
                        	}
                    	}
                	}
                };
                add_to_array(&event_to_client);
            }
        }
    }
}

static bool is_special_char(const char c) {
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

int find_random_k(int n) {
  	srand(time(NULL));
    int k;
    do {
        k = rand() % n;
    } while (k == 0 || gcd(k, n) != 1);
    return k;
}

int get_next_victim() {
	static int gcd_place = -1;
	if (gcd_place == -1) {
    	gcd_place = find_random_k(logo_height * logo_width);
        if (gcd_place == -1) {
        	//
            exit(0);
        }
	}
	static int x = 0;
    static int starting_num = 0; // має бути тей що і x

    int result = x;
    x = (x + gcd_place) % (logo_height * logo_width);
	if (x == starting_num) {
		return -1;
	}

    return result;
}

int iteration = 0;
static void add_random_logo_pixels_changes(size_t count) {
    for (size_t i = 0; i < count; i++) {
        size_t y, x;
        char ch;

        int victim = get_next_victim();
        if (victim == -1) {
        	iteration =  -1;
            return;
        }
        y = victim / logo_width;
        x = victim % logo_width;
        ch = logo[y][x];
        if (!is_special_char(ch)) {
          	i--;
            continue;
        }

		SoToServerTransitBack event_to_client = {
            .tag = ToClient,
            .to_client = {
                .tag = DrawPixel,
                .draw_pixel = {
                    .x = x,
            	    .y = y,
                	.pixel_t = {
                    	.character = ch,
                    	.color_pair_id = RANDOM_COLOR_PAIR
                	}
            	}
        	}
		};
		add_to_array(&event_to_client);
    }
}

SoToServerTransitBackArray game_frame(ServerToSoTransitEvent *first_event,
                                      size_t length)
{
    global_array_length = 0;

	if (iteration == 0) {
		add_logo();
   	} else {
		add_random_logo_pixels_changes(1);
        if (iteration == -1) {
			SoToServerTransitBack event_end = {
       		 	.tag = ToServer,
       		 	.to_server = {
       		     	.tag = GoToState,
      		      	.go_to_state = Menu
      		  	}
    		};
        	add_to_array(&event_end);
		}
	}

    SoToServerTransitBackArray array = {
        .first_element = global_array,
        .length = global_array_length,
    };

    iteration++;
    return array;
}
