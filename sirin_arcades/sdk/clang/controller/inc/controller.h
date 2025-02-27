#ifndef CONTROLLER_H
#define CONTROLLER_H

typedef enum {
    W = 'w',
    A = 'a',
    S = 's',
    D = 'd',
    SPACE = ' ',
    C = 'c',
    END,
  } keys;

char *get_keys(void);

#endif // CONTROLLER_H
