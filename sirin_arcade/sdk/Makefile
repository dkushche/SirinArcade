.PHONY: all clean

CC = gcc
CFLAGS = -Wall -fPIC -I.
LDFLAGS = -shared -lncurses

SRC = src/render.c
OBJ = $(SRC:.c=.o)
TARGET = libsirinarcadesdk.so

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJ) $(TARGET)

install:
ifeq ($(strip $(INSTALL_DIR)),)
	@echo "Install directory not set"
	@exit 1
endif

	cp -f $(TARGET) $(INSTALL_DIR)/usr/lib
	rm -rf $(INSTALL_DIR)/usr/include/sirin_arcade
	cp -rf public $(INSTALL_DIR)/usr/include/sirin_arcade
