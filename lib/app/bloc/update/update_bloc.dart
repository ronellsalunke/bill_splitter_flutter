import 'package:bs_flutter/app/models/update/mock_update_manifest.dart';
import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_event.dart';
import 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  static const _lastSeenBuildNumberKey = 'last_seen_build_number';
  static const _lastShownChangelogBuildNumberKey = 'last_shown_changelog_build_number';

  final AppRepository _repository;
  final SharedPreferences _prefs;
  final Future<PackageInfo> Function() _packageInfoFactory;
  final Future<UpdateManifest?> Function(PackageInfo packageInfo)? _debugManifestFactory;
  bool _bannerDismissed = false;

  UpdateBloc(
    this._repository,
    this._prefs, {
    Future<PackageInfo> Function()? packageInfoFactory,
    Future<UpdateManifest?> Function(PackageInfo packageInfo)? debugManifestFactory,
  }) : _packageInfoFactory = packageInfoFactory ?? PackageInfo.fromPlatform,
       _debugManifestFactory = debugManifestFactory,
       super(UpdateInitial()) {
    on<CheckForUpdate>(_onCheckForUpdate);
    on<DismissUpdateBanner>(_onDismissUpdateBanner);
    on<AcknowledgeUpdateChangelog>(_onAcknowledgeUpdateChangelog);
  }

  Future<void> _onCheckForUpdate(CheckForUpdate event, Emitter<UpdateState> emit) async {
    if (_bannerDismissed) {
      emit(UpdateBannerDismissed());
      return;
    }

    emit(UpdateChecking());
    try {
      final packageInfo = await _packageInfoFactory();
      final debugManifest = _debugManifestFactory != null
          ? await _debugManifestFactory(packageInfo)
          : kDebugMode
          ? buildMockInstalledUpdateManifest(packageInfo)
          : null;
      final manifest = debugManifest ?? await _repository.fetchUpdateManifest();

      final currentVersion = Version.parse(packageInfo.version);
      final latestVersion = Version.parse(manifest.latestVersion.replaceFirst(RegExp('^v'), ''));
      final currentBuildNumber = int.parse(packageInfo.buildNumber);
      final previousBuildNumber = _prefs.getInt(_lastSeenBuildNumberKey);
      final shownChangelogBuildNumber = _prefs.getInt(_lastShownChangelogBuildNumberKey);
      final currentRelease = manifest.releaseFor(version: packageInfo.version, buildNumber: currentBuildNumber);

      if (previousBuildNumber != currentBuildNumber) {
        await _prefs.setInt(_lastSeenBuildNumberKey, currentBuildNumber);
      }

      final hasUpgraded = previousBuildNumber != null && currentBuildNumber > previousBuildNumber;
      final shouldShowChangelog =
          hasUpgraded &&
          shownChangelogBuildNumber != currentBuildNumber &&
          currentRelease != null &&
          currentRelease.changes.isNotEmpty;
      final shouldShowMockChangelog =
          kDebugMode &&
          manifest.debugForceShowInstalledReleaseChangelog &&
          shownChangelogBuildNumber != currentBuildNumber &&
          currentRelease != null &&
          currentRelease.changes.isNotEmpty;

      if (shouldShowMockChangelog || shouldShowChangelog) {
        emit(UpdateChangelogAvailable(currentRelease));
        return;
      }

      if (latestVersion > currentVersion && manifest.latestBuildNumber > currentBuildNumber) {
        emit(UpdateAvailable(manifest));
      } else {
        emit(UpdateNotAvailable());
      }
    } catch (_) {
      emit(UpdateNotAvailable());
    }
  }

  void _onDismissUpdateBanner(DismissUpdateBanner event, Emitter<UpdateState> emit) {
    _bannerDismissed = true;
    emit(UpdateBannerDismissed());
  }

  Future<void> _onAcknowledgeUpdateChangelog(AcknowledgeUpdateChangelog event, Emitter<UpdateState> emit) async {
    final packageInfo = await _packageInfoFactory();
    final currentBuildNumber = int.parse(packageInfo.buildNumber);
    await _prefs.setInt(_lastShownChangelogBuildNumberKey, currentBuildNumber);
  }
}
