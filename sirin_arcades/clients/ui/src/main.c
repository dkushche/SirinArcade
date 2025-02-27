#include <stddef.h>
#include <stdlib.h>

#include <arpa/inet.h>
#include <stdio.h>
#include <memory.h>

#include <terminal-drawer.h>
#include <events-bus.h>
#include <controller.h>
#include <resource_loader.h>

int main(void)
{
    screen_t *screen = initialze_screen();
    if (screen == NULL)
    {
        return 1;
    }

//    void *busclientconnection = connect_to_bus();

//    send_resolution(busclientconnection, 240, 30); // possibly failed
//
//    ClientToServerEvent next_message = {
//        .tag = PressedButton22222222,
//    	.pressed_button22222222 = {
//    	   .SOME_THING = 6666
//    	}
//    };

//    int yeah = 0;

    // todo busybox httpd -h $1 -p 5576 out/etc/sirin_arcades/arcades_resources
    //         стянуть logo/intro.wav, сравнить размер и контент
    //

	int blyaha = 0;
    while (1){
        {
            char *ch = get_keys();
            while (*ch != END) {
                printf("%d %c ", blyaha, *ch);
                ch++;
            }
            printf("\n");
            blyaha++;
        }

//      	if (yeah == 0)
//        {
//      		send_event(busclientconnection, &next_message); //possibly failed
//            yeah = 1;
//        }
//
//        SoToClient received_message;
//      	bool connection_closed;
//
//      	receive_event(busclientconnection, &received_message, &connection_closed);
//
//        if (connection_closed)
//        {
//    	    goto the_end;
//        }
//
//        printf("%c ", received_message.draw_pixel.pixel_t.character);
//        fflush(stdout);
//
        sleep(1);
    }

//    the_end:
//        cleanup_bus(busclientconnection);



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
