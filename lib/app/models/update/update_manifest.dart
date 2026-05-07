import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_manifest.freezed.dart';

part 'update_manifest.g.dart';

@freezed
abstract class UpdateManifest with _$UpdateManifest {
  factory UpdateManifest({required String latestVersion, required int latestBuildNumber, String? message}) = _UpdateManifest;

  factory UpdateManifest.fromJson(Map<String, dynamic> json) => _$UpdateManifestFromJson(json);
}
