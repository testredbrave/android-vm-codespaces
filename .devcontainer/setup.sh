#!/bin/bash
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin 

# Install Android SDK
wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
unzip -q commandlinetools-linux-*.zip -d cmdline-tools
mkdir -p android-sdk/cmdline-tools/latest
mv cmdline-tools/cmdline-tools/* android-sdk/cmdline-tools/latest/

# Setup environment
export ANDROID_SDK_ROOT="$PWD/android-sdk"
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin

# Accept licenses
mkdir -p ~/.android
echo "count = 999" > ~/.android/repositories.cfg
yes | sdkmanager --licenses > /dev/null

# Install minimal packages
sdkmanager "platform-tools" "emulator" "platforms;android-33" "system-images;android-33;google_apis;x86_64"

# Create AVD
avdmanager create avd -n android33 -k "system-images;android-33;google_apis;x86_64" -d pixel -c 512M

# Optimize AVD config
echo "hw.ramSize=1024" >> ~/.android/avd/android33.avd/config.ini
echo "vm.heapSize=128" >> ~/.android/avd/android33.avd/config.ini
echo "disk.cachePartition=yes" >> ~/.android/avd/android33.avd/config.ini

# Start emulator (headless)
nohup emulator -avd android33 -no-window -no-audio -gpu swiftshader_indirect -memory 1024 -no-snapshot > /dev/null 2>&1 &

# Wait for device
adb wait-for-device
while [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" != "1" ]; do
  sleep 2
done

echo "Android emulator ready! Use 'adb devices' to check"
