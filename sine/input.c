#include "sine.h"


unsigned int getjoystatus(unsigned int j)
{
  return sine_controllers[j];
}

void clearjoy(unsigned int j)
{
  sine_controllers[j] = 0;
}
