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

void add_to_array(char element);

#endif // CONTROLLER_H
