import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/app_info.dart';

void main() {
  test('About page version matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*([^+\s]+)', multiLine: true).firstMatch(pubspec)!.group(1);
    expect(appVersion, version);
  });
}
