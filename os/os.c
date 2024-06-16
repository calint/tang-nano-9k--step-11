#include "os_config.h"

void print_pointer_address(void *ptr);

void run() {
  print_pointer_address((void *)0);
}

void print_pointer_address(void *ptr) {
  const unsigned address = (unsigned)ptr;
  *leds = (char)address;
  while(1);
  // int i = 0;
  // while(i--);
}

