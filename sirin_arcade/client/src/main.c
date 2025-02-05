#include <stddef.h>
#include <stdlib.h>

#include <sirin_arcade/render.h>

#include <arpa/inet.h>
#include <stdio.h>
#include <memory.h>
#include "../../server/communication-data/bindings.h" // problem

int main(void)
{
    int sock;
    struct sockaddr_in server_addr;

    char response[1024];

    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket creation failed");
        exit(0);
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(9877);

    if (bind(sock, (const struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("bind failed");
        close(sock);
        exit(0);
    }

    printf("Listening for UDP messages on port 9877...\n");

    {
        struct sockaddr_in sender;
        socklen_t len = sizeof(sender);
        ssize_t n = recvfrom(sock, response, 1024 - 1, 0,
                             (struct sockaddr *)&sender, &len);
        if (n < 0) {
            perror("recvfrom failed");
            exit(0);
        }
        response[n] = '\0';
        char ip_str[INET_ADDRSTRLEN];

        if (inet_ntop(AF_INET, &sender.sin_addr, ip_str, sizeof(ip_str)) == NULL)
        {
	        perror("inet_ntop");
	        exit(EXIT_FAILURE);
        }
        printf("Received message: %s from %s:%u\n", response, ip_str, ntohs(sender.sin_port));

        close(sock);

		int tcp_sock;
        if ((tcp_sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
            perror("TCP socket creation failed");
            exit(0);
        }

        struct sockaddr_in tcp_server_addr;
        memset(&tcp_server_addr, 0, sizeof(tcp_server_addr));
        tcp_server_addr.sin_family = AF_INET;
        tcp_server_addr.sin_port = htons(9876);
        tcp_server_addr.sin_addr.s_addr = sender.sin_addr.s_addr;

        if (connect(tcp_sock, (struct sockaddr *)&tcp_server_addr, sizeof(tcp_server_addr)) < 0) {
            perror("TCP connection failed");
            close(tcp_sock);
            exit(0);
        }

        unsigned char message[2] = {240, 30};

        if (send(tcp_sock, message, sizeof(message), 0) < 0) {
            perror("send failed");
            close(tcp_sock);
            exit(0);
        }

        ClientToServerEvent next_message = {
            .tag = PressedButton22222222,
    		.pressed_button22222222 = {
     		   .SOME_THING = 6666
    		}
        };


		int yeah = 0;
        while (1){
          	if (yeah == 0) {
          		if (send(tcp_sock, &next_message, sizeof(next_message), 0) < 0) {
            		perror("send failed");
            		close(tcp_sock);
            		exit(0);
       			}
                yeah = 1;
            }

            {
	            ssize_t total_received = 0;
	            SoToClient received_message;

	            while (total_received < sizeof(received_message))
	            {
		            ssize_t bytes_received = recv(tcp_sock, ((char*)&received_message) + total_received,
		                                          sizeof(received_message) - total_received, 0);

		            if (bytes_received < 0)
		            {
			            perror("recv failed");
			            close(tcp_sock);
			            exit(0);
		            }

		            total_received += bytes_received;

		            if (bytes_received == 0)
		            {
			            goto THE_END;
		            }
	            }
	            printf("%c ", received_message.draw_pixel.pixel_t.character);
	            fflush(stdout);
            }

            sleep(1);
        }


    THE_END:
        close(tcp_sock);
    }



    return 0;

//    screen_t *screen = initialze_screen();
//    if (screen == NULL)
//    {
//        return 1;
//    }
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
//    free_screen(screen);

    return 0;
}
