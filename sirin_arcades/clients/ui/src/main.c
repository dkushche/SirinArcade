#include <stddef.h>
#include <stdlib.h>

#include <stdio.h>

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
                //temp
                fprintf(stderr, "%d %d %c \n", received_message.draw_pixel.y,
                      received_message.draw_pixel.x,
                      received_message.draw_pixel.pixel_t.character);
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
                char *resolved_path = resolve_resource(received_message.play_resource.data);
                if (resolved_path == NULL) {
                	fprintf(stderr, "Program can not continue executing due to problem with playing resource not present on machine");
                    return false;
                }
            	play_wave(resolved_path, false, &sound); // not sure if it is the right usage
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
        fprintf(stderr, "Program can not continue executing due to problem with screen initing");
        exit(1);
    }

    void *busclientconnection = connect_to_bus(screen->width, screen->height);
    if (busclientconnection == NULL) {
        fprintf(stderr, "Program can not continue executing due to problem with connecting to server");
        exit(1);
    }

    int8_t handshake_result = make_handshake(busclientconnection);
	if (handshake_result != NULL) {
		fprintf(stderr, "Program can not continue executing due to problem with handshake, problem code: %d", handshake_result);
		goto the_end;
	}

    while (1) {
        send_keys(busclientconnection);

        if (!receive_message(busclientconnection)) {
        	goto the_end;
        }
    }

    the_end:
        cleanup_bus(busclientconnection);
        fprintf(stderr, "Program finishing its execution");

    tui_io_deinit();

    return 0;
}
