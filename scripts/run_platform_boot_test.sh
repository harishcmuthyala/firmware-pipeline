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

mkdir -p "$VDISK"
mkdir -p "$(dirname "$LOG_FILE")"

# Copy every .efi app that was actually built -- no hardcoded names
cp "$APP_DIR"/*.efi "$VDISK"/ 2>/dev/null || true

# Build a startup.nsh that runs every app found, then resets
echo '@echo -off' > "$VDISK/startup.nsh"
for app in "$VDISK"/*.efi; do
  [ -e "$app" ] || continue
  echo "$(basename "$app")" >> "$VDISK/startup.nsh"
done
echo 'reset -s' >> "$VDISK/startup.nsh"

timeout 30 xvfb-run -a qemu-system-x86_64 \
  -drive if=pflash,format=raw,readonly=on,file="$FW_DIR/OVMF_CODE.fd" \
  -drive if=pflash,format=raw,file="$FW_DIR/OVMF_VARS.fd" \
  -drive format=raw,file=fat:rw:"$VDISK" \
  -m 256M -net none -nographic > "$LOG_FILE" 2>&1 || true

echo "----- Boot output -----"
cat "$LOG_FILE"
echo "------------------------"