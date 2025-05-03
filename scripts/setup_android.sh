#!/bin/bash
# Install package utama
sdkmanager --install "platform-tools" "emulator" "platforms;android-34" "system-images;android-34;google_apis;x86_64"

# Buat AVD
avdmanager create avd -n android34 -k "system-images;android-34;google_apis;x86_64" -d pixel

# Optimasi RAM
echo "hw.ramSize=2048" >> ~/.android/avd/android34.avd/config.ini

# Jalankan emulator di background
nohup emulator -avd android34 -no-window -no-audio -gpu swiftshader_indirect > emulator.log 2>&1 &

# Tunggu hingga emulator siap
adb wait-for-device
while [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" != "1" ]; do
  sleep 2
done
echo "Emulator siap digunakan!"
