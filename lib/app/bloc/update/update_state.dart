import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:equatable/equatable.dart';

abstract class UpdateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateInitial extends UpdateState {}

class UpdateChecking extends UpdateState {}

class UpdateNotAvailable extends UpdateState {}

class UpdateAvailable extends UpdateState {
  UpdateAvailable(this.manifest);

  final UpdateManifest manifest;

  @override
  List<Object?> get props => [manifest];
}

class UpdateChangelogAvailable extends UpdateState {
  UpdateChangelogAvailable(this.release);

  final UpdateRelease release;

  @override
  List<Object?> get props => [release];
}

class UpdateBannerDismissed extends UpdateState {}
