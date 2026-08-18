#!/bin/bash
# Generic: boots the platform firmware + whatever apps were built,
# and saves the output to a log. Doesn't know or care WHICH apps
# exist -- new apps just get picked up automatically.
set -e

EDK2_DIR="edk2"
FW_DIR="$EDK2_DIR/Build/OvmfX64/DEBUG_GCC/FV"
APP_DIR="$EDK2_DIR/Build/ServerPlatform/DEBUG_GCC/X64"
VDISK="$EDK2_DIR/vdisk"
LOG_FILE="Tests/BootTests/boot_output.log"

mkdir -p "$VDISK/EFI/BOOT"
mkdir -p "$(dirname "$LOG_FILE")"

# Place the first built app at the spec-standard direct-boot path.
# Firmware will boot straight into it -- no interactive Shell,
# no Boot Manager Menu, no keystrokes needed at all.
FIRST_APP=$(ls "$APP_DIR"/*.efi 2>/dev/null | head -n 1)
if [ -n "$FIRST_APP" ]; then
  cp "$FIRST_APP" "$VDISK/EFI/BOOT/BOOTX64.EFI"
fi

timeout 30 xvfb-run -a qemu-system-x86_64 \
  -drive if=pflash,format=raw,readonly=on,file="$FW_DIR/OVMF_CODE.fd" \
  -drive if=pflash,format=raw,file="$FW_DIR/OVMF_VARS.fd" \
  -drive format=raw,file=fat:rw:"$VDISK" \
  -m 256M -net none -nographic > "$LOG_FILE" 2>&1 || true

echo "----- Boot output -----"
cat "$LOG_FILE"
echo "------------------------"