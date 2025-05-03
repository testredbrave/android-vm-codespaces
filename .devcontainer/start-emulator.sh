#!/bin/bash

echo "Starting Android Emulator..."

# Create emulator if not exists
echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis;x86" || true

# Start emulator in headless mode
emulator -avd test -no-snapshot -no-window -gpu off &
adb wait-for-device

echo "✅ Emulator is now running."
