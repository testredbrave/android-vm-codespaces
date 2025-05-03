#!/bin/bash
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"

yes | sdkmanager --licenses >/dev/null
sdkmanager "platform-tools" "emulator" "platforms;android-34" "system-images;android-34;google_apis;x86_64"

avdmanager create avd -n android34 -k "system-images;android-34;google_apis;x86_64" -d pixel

nohup emulator -avd android34 -no-window -no-audio -gpu swiftshader_indirect -memory 2048 >/dev/null 2>&1 &
adb wait-for-device