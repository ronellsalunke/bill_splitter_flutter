import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:equatable/equatable.dart';

sealed class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

final class UpdateInitial extends UpdateState {
  const UpdateInitial();
}

final class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

final class UpdateNotAvailable extends UpdateState {
  const UpdateNotAvailable();
}

final class UpdateAvailable extends UpdateState {
  const UpdateAvailable(this.manifest);

  final UpdateManifest manifest;

  @override
  List<Object?> get props => [manifest];
}

final class UpdateChangelogAvailable extends UpdateState {
  const UpdateChangelogAvailable(this.release);

  final UpdateRelease release;

  @override
  List<Object?> get props => [release];
}

final class UpdateBannerDismissed extends UpdateState {
  const UpdateBannerDismissed();
}
