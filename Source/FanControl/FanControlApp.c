#include <Uefi.h>
#include <Library/UefiLib.h>
#include <Library/UefiApplicationEntryPoint.h>
#include "FanControl.h"

EFI_STATUS
EFIAPI
UefiMain (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  int          SimulatedTempC;
  unsigned int FanSpeed;

  SimulatedTempC = 95;  // pretending this came from a real sensor
  FanSpeed = GetFanSpeedPercent (SimulatedTempC);

  Print (L"=== Fan Control (real firmware) ===\n");
  Print (L"Simulated temperature: %d C\n", SimulatedTempC);
  Print (L"Fan speed decided:     %d %%\n", FanSpeed);

  if (SimulatedTempC > 90) {
    Print (L"ALERT: threshold exceeded, fan at max\n");
  } else {
    Print (L"OK\n");
  }

  return EFI_SUCCESS;
}