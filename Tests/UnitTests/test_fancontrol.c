#include <stdio.h>
#include <assert.h>
#include "FanControl.h"

int main (void) {
  assert (GetFanSpeedPercent (30)  == 20);   // cool
  assert (GetFanSpeedPercent (49)  == 20);   // just under the first tier
  assert (GetFanSpeedPercent (50)  == 50);   // right at the boundary
  assert (GetFanSpeedPercent (65)  == 50);   // warm
  assert (GetFanSpeedPercent (70)  == 80);   // right at the next boundary
  assert (GetFanSpeedPercent (85)  == 80);   // hot
  assert (GetFanSpeedPercent (90)  == 100);  // right at the danger boundary
  assert (GetFanSpeedPercent (120) == 100);  // very hot

  printf ("All fan control tests passed.\n");
  return 0;
}