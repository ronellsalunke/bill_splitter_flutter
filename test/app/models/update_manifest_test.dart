import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes update manifest from json', () {
    final manifest = UpdateManifest.fromJson({'latestVersion': '1.0.8', 'latestBuildNumber': 8, 'message': 'Update available'});

    expect(manifest.latestVersion, '1.0.8');
    expect(manifest.latestBuildNumber, 8);
    expect(manifest.message, 'Update available');
  });
}
