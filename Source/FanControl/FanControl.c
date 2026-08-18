#include "FanControl.h"

// Simple tiered logic: hotter temperature -> faster fan.
unsigned int
GetFanSpeedPercent (
  int TempC
  )
{
  if (TempC < 50) {
    return 20;
  } else if (TempC < 70) {
    return 50;
  } else if (TempC < 90) {
    return 80;
  } else {
    return 100;
  }
}