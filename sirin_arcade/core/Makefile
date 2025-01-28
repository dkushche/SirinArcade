
CC = gcc
CFLAGS = -Wall -g
LDFLAGS = -lsirinarcadesdk -lncurses

OUTPUT = sirin_arcade

SRC = src/main.c
OBJ = $(SRC:.c=.o)

all: $(OUTPUT)

$(OUTPUT): $(OBJ)
	$(CC) $(OBJ) -o $(OUTPUT) $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ) $(OUTPUT)

.PHONY: all clean
