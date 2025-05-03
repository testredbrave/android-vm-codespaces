#!/bin/bash
# Install platform tools
sdkmanager --install "platform-tools" "emulator" "platforms;android-34" "system-images;android-34;google_apis;x86_64"

# Create AVD
avdmanager create avd -n android34 -k "system-images;android-34;google_apis;x86_64" -d pixel

# Optimize config
echo "hw.ramSize=2048" >> ~/.android/avd/android34.avd/config.ini
echo "vm.heapSize=256" >> ~/.android/avd/android34.avd/config.ini

# Start emulator
nohup emulator -avd android34 -no-window -no-audio -gpu swiftshader_indirect > /dev/null 2>&1 &
adb wait-for-device
