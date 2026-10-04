# Kakeibo

A personal, offline budgeting app for Android based on the Japanese Kakeibo method,
in Kuwaiti Dinar. No accounts, no internet, no ads: everything stays on the phone.

## Build and install

```
dart run build_runner build
flutter analyze
flutter test
flutter build apk --release --target-platform android-arm64
~/Library/Android/sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Check the release APK has no INTERNET permission:

```
~/Library/Android/sdk/build-tools/36.0.0/aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```

## Release signing

Release builds are signed with a private key kept outside the repo
(`android/key.properties` points to it; both are git-ignored). Back up the key
folder: without it, a new build can't update the installed app. The build fails
on purpose if the key is missing rather than signing with a different key.

## Backups

Settings → Back up writes one JSON file with all data. Copy it to your laptop.
Settings → Restore validates a backup, shows what it contains, and replaces everything.
