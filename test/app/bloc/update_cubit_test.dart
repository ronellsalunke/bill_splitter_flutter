import 'dart:async';

import 'package:bs_flutter/app/bloc/update/update_cubit.dart';
import 'package:bs_flutter/app/bloc/update/update_state.dart';
import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAppRepository extends Mock implements AppRepository {}

PackageInfo _packageInfo({required String version, required String buildNumber}) {
  return PackageInfo(
    appName: 'bill splitter',
    packageName: 'com.ronell.billsplitter',
    version: version,
    buildNumber: buildNumber,
  );
}

UpdateManifest _manifest({required String version, required int buildNumber}) {
  return UpdateManifest(latestVersion: version, latestBuildNumber: buildNumber, message: 'Update available');
}

void main() {
  late MockAppRepository repository;
  late SharedPreferences prefs;

  setUp(() async {
    repository = MockAppRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('emits update available when version and build are newer', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.8', buildNumber: 8));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateAvailable>()]));

    await cubit.checkForUpdate();

    await expectation;
    await cubit.close();
  });

  test('emits no update when version and build are the same', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.7', buildNumber: 7));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    await cubit.checkForUpdate();

    await expectation;
    await cubit.close();
  });

  test('uses the mock manifest when debug mode is injected', () async {
    final cubit = UpdateCubit(
      repository,
      prefs,
      isDebugMode: true,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateChangelogAvailable>()]));

    await cubit.checkForUpdate();

    await expectation;
    verifyNever(() => repository.fetchUpdateManifest());
    await cubit.close();
  });

  test('emits no update when only version is newer', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.8', buildNumber: 7));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    await cubit.checkForUpdate();

    await expectation;
    await cubit.close();
  });

  test('emits no update when only build is newer', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.7', buildNumber: 8));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    await cubit.checkForUpdate();

    await expectation;
    await cubit.close();
  });

  test('emits no update for an invalid manifest version', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: 'invalid', buildNumber: 8));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    await cubit.checkForUpdate();

    await expectation;
    await cubit.close();
  });

  test('dismiss suppresses checks for the current cubit session', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.8', buildNumber: 8));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emits(isA<UpdateBannerDismissed>()));

    cubit.dismissBanner();
    await cubit.checkForUpdate();

    await expectation;
    verifyNever(() => repository.fetchUpdateManifest());
    await cubit.close();
  });

  test('coalesces duplicate checks into the in-flight operation', () async {
    final packageInfoCompleter = Completer<PackageInfo>();
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.8', buildNumber: 8));
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () => packageInfoCompleter.future,
      debugManifestFactory: (_) async => null,
    );
    final emittedStates = <UpdateState>[];
    final subscription = cubit.stream.listen(emittedStates.add);

    final firstCheck = cubit.checkForUpdate();
    final duplicateCheck = cubit.checkForUpdate();
    packageInfoCompleter.complete(_packageInfo(version: '1.0.7', buildNumber: '7'));
    await Future.wait([firstCheck, duplicateCheck]);
    await Future<void>.delayed(Duration.zero);

    expect(emittedStates, [isA<UpdateChecking>(), isA<UpdateAvailable>()]);
    verify(() => repository.fetchUpdateManifest()).called(1);
    await subscription.cancel();
    await cubit.close();
  });

  test('dismiss remains authoritative while a check is running', () async {
    final packageInfoCompleter = Completer<PackageInfo>();
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () => packageInfoCompleter.future,
      debugManifestFactory: (_) async => null,
    );
    final emittedStates = <UpdateState>[];
    final subscription = cubit.stream.listen(emittedStates.add);

    final check = cubit.checkForUpdate();
    cubit.dismissBanner();
    packageInfoCompleter.complete(_packageInfo(version: '1.0.7', buildNumber: '7'));
    await check;
    await Future<void>.delayed(Duration.zero);

    expect(emittedStates, [isA<UpdateChecking>(), isA<UpdateBannerDismissed>()]);
    expect(cubit.state, isA<UpdateBannerDismissed>());
    verifyNever(() => repository.fetchUpdateManifest());
    await subscription.cancel();
    await cubit.close();
  });

  test('persists changelog acknowledgement before rechecking', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async {
      expect(prefs.getInt('last_shown_changelog_build_number'), 7);
      return _manifest(version: '1.0.7', buildNumber: 7);
    });
    final cubit = UpdateCubit(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );
    final expectation = expectLater(cubit.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    await cubit.acknowledgeChangelogAndRecheck();

    await expectation;
    expect(prefs.getInt('last_shown_changelog_build_number'), 7);
    await cubit.close();
  });
}
