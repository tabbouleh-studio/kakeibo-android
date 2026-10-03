# Kakeibo

A personal, offline budgeting app for Android based on the Japanese Kakeibo method,
in Kuwaiti Dinar. No accounts, no internet, no ads: everything stays on the phone.

## Build and install

```
dart run build_runner build
flutter analyze
flutter test
flutter build apk --release
~/Library/Android/sdk/platform-tools/adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Check the release APK has no INTERNET permission:

```
~/Library/Android/sdk/build-tools/36.0.0/aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```

## Backups

Settings → Back up writes one JSON file with all data. Copy it to your laptop.
Settings → Restore validates a backup, shows what it contains, and replaces everything.
