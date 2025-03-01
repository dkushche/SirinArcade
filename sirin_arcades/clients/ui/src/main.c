#include <stddef.h>
#include <stdlib.h>

#include <arpa/inet.h>
#include <stdio.h>
#include <memory.h>

#include <terminal-drawer.h>
#include <events-bus.h>
#include <controller.h>
#include <resource-loader.h>

int main(void)
{
    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        return 1;
    }

    void *busclientconnection = connect_to_bus();

    send_resolution(busclientconnection, 240, 30); // possibly failed

    int yeah = 0;

    while (1) {
        {
            char *ch = get_keys();
            while (*ch != END) {
                ClientToServerEvent next_message = {
                    .tag = PressedButton,
    	            .pressed_button = {
    	                .button = *ch
    	            }
                };
                send_event(busclientconnection, &next_message); //possibly failed
                ch++;
            }
        }

        SoToClient received_message;
      	bool connection_closed;

      	receive_event(busclientconnection, &received_message, &connection_closed);

        if (connection_closed)
        {
    	    goto the_end;
        }

        switch (received_message.tag) {
            case DrawPixel:
                printf("%c ", received_message.draw_pixel.pixel_t.character); //
                break;
            case LoadResource:
                load_resource(received_message.load_resource.data);
                break;
            case PlayResource:
                void *lol = NULL;
                play_wave(received_message.play_resource.data, false, &lol); // not sure if it is the right usage
                break;
            case CleanResources:
                clean_resources();
                break;
        }
        fflush(stdout); //
    }

    the_end:
        cleanup_bus(busclientconnection);

    free_screen(screen);

    return 0;


//
//    pixel_t *pixel = create_pixel('X', ARCADE_YELLOW);

    while (1)
    {
//        draw(screen, 0, 0, pixel);
//        draw(screen, 0, screen->width - 1, pixel);
//        draw(screen, screen->height - 1, 0, pixel);
//        draw(screen, screen->height / 2, screen->width / 2, pixel);
//        draw(screen, screen->height - 1, screen->width - 1, pixel);
//
//        render(screen);
    }

//    free(pixel);
//

    return 0;
}
