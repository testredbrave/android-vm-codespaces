#!/bin/bash

# Config
AVD_NAME="test"
ANDROID_VERSION="30"
CPU_ARCH="x86_64"  # Lebih kompatibel dengan ARM
RAM_SIZE="1024"
HEAP_SIZE="256"
LOG_FILE="emulator.log"

echo "Starting Android Emulator..."

# Create AVD if not exists
if ! avdmanager list avd | grep -q "$AVD_NAME"; then
  echo "no" | avdmanager create avd \
    -n "$AVD_NAME" \
    -k "system-images;android-$ANDROID_VERSION;google_apis;$CPU_ARCH" \
    -d pixel || exit 1
fi

# Optimize AVD config
CONFIG_FILE="$HOME/.android/avd/${AVD_NAME}.avd/config.ini"
echo "hw.ramSize=$RAM_SIZE" >> "$CONFIG_FILE"
echo "vm.heapSize=$HEAP_SIZE" >> "$CONFIG_FILE"

# Start emulator with logging
emulator -avd "$AVD_NAME" \
  -no-snapshot \
  -no-window \
  -gpu swiftshader_indirect \
  -memory "$RAM_SIZE" \
  -logcat "*:W" \
  > "$LOG_FILE" 2>&1 &

# Wait with timeout
timeout 60 adb wait-for-device
if [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = "1" ]; then
  echo "✅ Emulator ready! Device list:"
  adb devices
else
  echo "❌ Emulator failed to start. Last log:"
  tail -n 20 "$LOG_FILE"
  exit 1
fi
