#include <stddef.h>
#include <stdlib.h>

#include <arpa/inet.h>
#include <stdio.h>
#include <memory.h>

#include <events_bus.h>
#include <tui_io.h>
#include <resource_loader.h>

static bool receive_message(void *busclientconnection) {
	SoToClient received_message;
    bool connection_closed;

    receive_event(busclientconnection, &received_message, &connection_closed);

    if (connection_closed) {
    	return false;
    }

    switch (received_message.tag) {
        	case DrawPixel:
            	set_pixel(received_message.draw_pixel.y,
                      received_message.draw_pixel.x,
                      received_message.draw_pixel.pixel_t.color_pair_id,
                      received_message.draw_pixel.pixel_t.character
                      );
        		render();
            	break;
        	case LoadResource:
        	    load_resource(received_message.load_resource.data);
                break;
    	    case PlayResource:
	            void *sound = NULL;
                // todo resolve received_message.play_resource.data and play_wave result
            	play_wave(received_message.play_resource.data, false, &sound); // not sure if it is the right usage
            	break;
        	case CleanResources:
            	clean_resources();
        	    break;
        }
    return true;
}

static void send_keys(void *busclientconnection) {
	char *ch = get_keys();

    while (*ch != ((char) END)) {
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

int main(void)
{
    screen_t *screen = tui_io_init();
    if (screen == NULL) {
    	//todo panic
        exit(0);
    }

    void *busclientconnection = connect_to_bus(screen->width, screen->height);

    // todo make_handshake(busclientconnection)  sending 0u8

    while (1) {
        send_keys(busclientconnection);

        if (!receive_message(busclientconnection)) {
        	goto the_end;
        }
    }

    the_end:
        cleanup_bus(busclientconnection);

    tui_io_deinit();

    return 0;
}
