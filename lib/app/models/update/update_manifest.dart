import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_manifest.freezed.dart';

part 'update_manifest.g.dart';

@freezed
abstract class UpdateManifest with _$UpdateManifest {
  factory UpdateManifest({
    required String latestVersion,
    required int latestBuildNumber,
    String? message,
    @Default(<UpdateRelease>[]) List<UpdateRelease> releases,
  }) = _UpdateManifest;

  factory UpdateManifest.fromJson(Map<String, dynamic> json) => _$UpdateManifestFromJson(json);
}

@freezed
abstract class UpdateRelease with _$UpdateRelease {
  factory UpdateRelease({required String version, required int buildNumber, @Default(<String>[]) List<String> changes}) =
      _UpdateRelease;

  factory UpdateRelease.fromJson(Map<String, dynamic> json) => _$UpdateReleaseFromJson(json);
}

extension UpdateManifestX on UpdateManifest {
  UpdateRelease? releaseFor({required String version, required int buildNumber}) {
    final normalizedVersion = version.replaceFirst(RegExp('^v'), '');

    for (final release in releases) {
      final normalizedReleaseVersion = release.version.replaceFirst(RegExp('^v'), '');
      if (normalizedReleaseVersion == normalizedVersion && release.buildNumber == buildNumber) {
        return release;
      }
    }

    return null;
  }
}
