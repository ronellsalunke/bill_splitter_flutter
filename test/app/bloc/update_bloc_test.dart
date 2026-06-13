import 'package:bs_flutter/app/bloc/update/update_bloc.dart';
import 'package:bs_flutter/app/bloc/update/update_event.dart';
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
    final bloc = UpdateBloc(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );

    final expectation = expectLater(bloc.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateAvailable>()]));

    bloc.add(CheckForUpdate());
    await expectation;
    await bloc.close();
  });

  test('emits no update when version and build are the same', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.7', buildNumber: 7));
    final bloc = UpdateBloc(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );

    final expectation = expectLater(bloc.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    bloc.add(CheckForUpdate());
    await expectation;
    await bloc.close();
  });

  test('emits no update when only version is newer', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.8', buildNumber: 7));
    final bloc = UpdateBloc(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );

    final expectation = expectLater(bloc.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    bloc.add(CheckForUpdate());
    await expectation;
    await bloc.close();
  });

  test('emits no update when only build is newer', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.7', buildNumber: 8));
    final bloc = UpdateBloc(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );

    final expectation = expectLater(bloc.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    bloc.add(CheckForUpdate());
    await expectation;
    await bloc.close();
  });

  test('emits no update for invalid manifest version', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: 'invalid', buildNumber: 8));
    final bloc = UpdateBloc(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );

    final expectation = expectLater(bloc.stream, emitsInOrder([isA<UpdateChecking>(), isA<UpdateNotAvailable>()]));

    bloc.add(CheckForUpdate());
    await expectation;
    await bloc.close();
  });

  test('dismiss suppresses checks for the current bloc session', () async {
    when(() => repository.fetchUpdateManifest()).thenAnswer((_) async => _manifest(version: '1.0.8', buildNumber: 8));
    final bloc = UpdateBloc(
      repository,
      prefs,
      packageInfoFactory: () async => _packageInfo(version: '1.0.7', buildNumber: '7'),
      debugManifestFactory: (_) async => null,
    );

    final expectation = expectLater(bloc.stream, emits(isA<UpdateBannerDismissed>()));

    bloc.add(DismissUpdateBanner());
    bloc.add(CheckForUpdate());
    await expectation;
    await bloc.close();
    verifyNever(() => repository.fetchUpdateManifest());
  });
}
