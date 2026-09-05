import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_state.dart';

class UpdateCubit extends Cubit<UpdateState> {
  static const _lastSeenBuildNumberKey = 'last_seen_build_number';
  static const _lastShownChangelogBuildNumberKey = 'last_shown_changelog_build_number';

  UpdateCubit(
    this._repository,
    this._prefs, {
    Future<PackageInfo> Function()? packageInfoFactory,
      })
      : _packageInfoFactory = packageInfoFactory ?? PackageInfo.fromPlatform,
       super(UpdateInitial());

  final AppRepository _repository;
  final SharedPreferences _prefs;
  final Future<PackageInfo> Function() _packageInfoFactory;

  bool _bannerDismissed = false;
  Future<void>? _checkInProgress;

  Future<void> checkForUpdate() {
    if (_bannerDismissed) {
      emit(UpdateBannerDismissed());
      return Future<void>.value();
    }

    final checkInProgress = _checkInProgress;
    if (checkInProgress != null) return checkInProgress;

    late final Future<void> check;
    check = _performCheck().whenComplete(() {
      if (identical(_checkInProgress, check)) {
        _checkInProgress = null;
      }
    });
    _checkInProgress = check;
    return check;
  }

  void dismissBanner() {
    _bannerDismissed = true;
    emit(UpdateBannerDismissed());
  }

  Future<void> acknowledgeChangelogAndRecheck() async {
    final packageInfo = await _packageInfoFactory();
    final currentBuildNumber = int.parse(packageInfo.buildNumber);
    await _prefs.setInt(_lastShownChangelogBuildNumberKey, currentBuildNumber);
    await checkForUpdate();
  }

  Future<void> _performCheck() async {
    emit(UpdateChecking());

    try {
      final packageInfo = await _packageInfoFactory();
      if (_bannerDismissed) return;

      final manifest = await _repository.fetchUpdateManifest();
      if (_bannerDismissed) return;

      final currentVersion = Version.parse(packageInfo.version);
      final latestVersion = Version.parse(manifest.latestVersion.replaceFirst(RegExp('^v'), ''));
      final currentBuildNumber = int.parse(packageInfo.buildNumber);
      final previousBuildNumber = _prefs.getInt(_lastSeenBuildNumberKey);
      final shownChangelogBuildNumber = _prefs.getInt(_lastShownChangelogBuildNumberKey);
      final currentRelease = manifest.releaseFor(version: packageInfo.version, buildNumber: currentBuildNumber);

      final hasUpgraded = previousBuildNumber != null && currentBuildNumber > previousBuildNumber;
      final shouldShowChangelog =
          hasUpgraded &&
          shownChangelogBuildNumber != currentBuildNumber &&
          currentRelease != null &&
          currentRelease.changes.isNotEmpty;

      // Do not consume the upgrade signal while the manifest doesn't list the
      // current build yet (e.g. stale cache). Otherwise the changelog is lost forever.
      final shouldDeferSeenMarker = hasUpgraded && currentRelease == null;
      if (!shouldDeferSeenMarker && previousBuildNumber != currentBuildNumber) {
        await _prefs.setInt(_lastSeenBuildNumberKey, currentBuildNumber);
        if (_bannerDismissed) return;
      }

      if (shouldShowChangelog) {
        emit(UpdateChangelogAvailable(currentRelease));
      } else if (latestVersion > currentVersion || manifest.latestBuildNumber > currentBuildNumber) {
        emit(UpdateAvailable(manifest));
      } else {
        emit(UpdateNotAvailable());
      }
    } catch (_) {
      if (!_bannerDismissed) {
        emit(UpdateNotAvailable());
      }
    }
  }
}
