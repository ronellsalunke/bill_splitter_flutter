import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:package_info_plus/package_info_plus.dart';

UpdateManifest buildMockInstalledUpdateManifest(PackageInfo packageInfo) {
  final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

  return UpdateManifest(
    latestVersion: packageInfo.version,
    latestBuildNumber: currentBuildNumber,
    message: 'update available',
    debugForceShowInstalledReleaseChangelog: true,
    releases: [
      UpdateRelease(
        version: packageInfo.version,
        buildNumber: currentBuildNumber,
        changes: const [
          'Bill Splitter is better than ever!',
          'We have added a few new features, squashed some bugs and a lot more',
        ],
      ),
    ],
  );
}
