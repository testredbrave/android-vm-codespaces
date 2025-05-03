#!/bin/bash

# [Dihapus] Autentikasi Docker tidak diperlukan karena kita tidak pull image dari GHCR

# Install Android SDK dengan retry mechanism
for i in {1..3}; do
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && break
  sleep 5
done

unzip -q commandlinetools-linux-*.zip -d cmdline-tools
mkdir -p android-sdk/cmdline-tools/latest
mv cmdline-tools/cmdline-tools/* android-sdk/cmdline-tools/latest/

# Setup environment
export ANDROID_SDK_ROOT="$PWD/android-sdk"
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin

# Accept licenses dengan timeout
timeout 30 yes | sdkmanager --licenses || echo "License acceptance timeout"

# Install packages dengan versi lebih stabil
sdkmanager "platform-tools" "emulator" "platforms;android-30" "system-images;android-30;google_apis;x86_64"

# Create AVD dengan konfigurasi minimal
avdmanager create avd -n android30 -k "system-images;android-30;google_apis;x86_64" -d pixel -c 256M

# Optimize AVD config
config_file="$HOME/.android/avd/android30.avd/config.ini"
echo "hw.ramSize=1024" >> $config_file
echo "vm.heapSize=128" >> $config_file
echo "disk.cachePartition=yes" >> $config_file
echo "disk.cachePartition.size=128MB" >> $config_file

# Start emulator dengan logging
log_file="$PWD/emulator.log"
nohup emulator -avd android30 -no-window -no-audio -gpu swiftshader_indirect -memory 1024 -no-snapshot > $log_file 2>&1 &

# Wait for device dengan timeout
timeout 60 adb wait-for-device
if [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" = "1" ]; then
  echo "Android emulator ready!"
  adb devices
else
  echo "Emulator failed to boot. Check $log_file"
  tail -n 20 $log_file
  exit 1
fi
