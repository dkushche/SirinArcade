#include "../../../../server/communication-data/bindings.h" // problem
#include "stdio.h"
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

SoToServerTransitBack *global_array = NULL;
size_t global_array_capacity = 0;
size_t global_array_length = 0;

void add_to_array(SoToServerTransitBack *element) {
  if (global_array == NULL) {
    global_array_capacity = 10;
    global_array = (SoToServerTransitBack *)malloc(
        global_array_capacity * sizeof(SoToServerTransitBack));
  }

  if (global_array_length == global_array_capacity) {
    global_array_capacity = global_array_capacity * 2;
    global_array = (SoToServerTransitBack *)realloc(
        global_array, global_array_capacity * sizeof(SoToServerTransitBack));
  }

  global_array[global_array_length] = *element;
  global_array_length = global_array_length + 1;
}

void print_hex(const uint8_t *data, size_t length) {
  printf("[\n");
  for (size_t i = 0; i < length; i++) {
    printf("%02X", data[i]);
    if (i < length - 1) {
      printf(", ");
    }
  }
  printf("]\n");
}

SoToServerTransitBackArray game_frame(ServerToSoTransitEvent *first_event,
                                      size_t length) {
  printf("so starting handling events\n");
  global_array_length = 0;
  for (size_t i = 0; i < length; i++) {
    printf("Event %zu:\n", i);
    printf("  client_id: ");
    print_hex(first_event[i].client_id, SOCKET_ADDR_SIZE);
    printf("\n");

    // Дебаг інформація про underlying_event
    print_server_to_so_transit_event(first_event + i);

    bool is_client_id = false;
    for (size_t j = 0; j < SOCKET_ADDR_SIZE; j++) {
      if (first_event[j].client_id[j] != 0) {
        is_client_id = true;
        break;
      }
    }
    if (is_client_id) {
      ClientToServerEvent_Tag client_event_tag =
          first_event[i].underlying_event.client_event.tag;
      switch (client_event_tag) {
      case PressedButton:
        printf(
            "got button %u\n",
            first_event[i].underlying_event.client_event.pressed_button.button);
        break;
      case PressedButton22222222:
        printf("got SOME_THING %u\n", first_event[i]
                                           .underlying_event.client_event
                                           .pressed_button22222222.SOME_THING);
        break;
      default:
        printf("HERESY\n");
        break;
      }
    } else {
      ServerToSoEvent_Tag server_event_tag =
          first_event[i].underlying_event.server_event.tag;
      switch (server_event_tag) {
      case NewConnectionId:
        printf(
            "got new connection id %u\n",
            first_event[i].underlying_event.server_event.new_connection_id.id);
        break;
      default:
        printf("HERESY\n");
        break;
      }
    }
  }

  SoToServerTransitBack event_to_client = {
      .tag = ToClient,
      .to_client = {
          .tag = DrawPixel,
          .draw_pixel = {.x = 10,
                         .y = 15,
                         .pixel_t = {.character = (uint8_t)(48 + (rand() % 42)),
                                     .color_pair_id = 2}}}};

  add_to_array(&event_to_client);
  SoToServerTransitBackArray array = {
      .first_element = global_array,
      .length = global_array_length,
  };
  printf("so finished handling events\n");
  sleep(1);
  return array;
}
