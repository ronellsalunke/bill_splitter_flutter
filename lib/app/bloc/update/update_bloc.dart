import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'update_event.dart';
import 'update_state.dart';

class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final AppRepository _repository;
  final Future<PackageInfo> Function() _packageInfoFactory;
  bool _bannerDismissed = false;

  UpdateBloc(this._repository, {Future<PackageInfo> Function()? packageInfoFactory})
    : _packageInfoFactory = packageInfoFactory ?? PackageInfo.fromPlatform,
      super(UpdateInitial()) {
    on<CheckForUpdate>(_onCheckForUpdate);
    on<DismissUpdateBanner>(_onDismissUpdateBanner);
  }

  Future<void> _onCheckForUpdate(CheckForUpdate event, Emitter<UpdateState> emit) async {
    if (_bannerDismissed) {
      emit(UpdateBannerDismissed());
      return;
    }

    emit(UpdateChecking());
    try {
      final packageInfo = await _packageInfoFactory();
      final manifest = await _repository.fetchUpdateManifest();

      final currentVersion = Version.parse(packageInfo.version);
      final latestVersion = Version.parse(manifest.latestVersion.replaceFirst(RegExp('^v'), ''));
      final currentBuildNumber = int.parse(packageInfo.buildNumber);

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
}
