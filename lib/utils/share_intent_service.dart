import 'package:bs_flutter/app/routes/router.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  String? sharedImagePath;
  bool _pendingShareIntent = false;

  Future<void> initialize() async {
    // Handle initial shared media when app is launched from share
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        sharedImagePath = files.first.path;
        _pendingShareIntent = true;
        _tryNavigate();
      }
      ReceiveSharingIntent.instance.reset();
    });

    // Handle shared media when app is already running
    ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> files) {
      if (files.isNotEmpty) {
        sharedImagePath = files.first.path;
        _navigateToEditBill(fromShare: true);
      }
    });
  }

  void checkPendingShareIntent() {
    if (_pendingShareIntent) {
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      _pendingShareIntent = false;
      GoRouter.of(context).pushNamed('bill', pathParameters: {'id': 'new'}, extra: {'fromShare': true});
    }
  }

  void _navigateToEditBill({bool fromShare = false}) {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).pushNamed('bill', pathParameters: {'id': 'new'}, extra: fromShare ? {'fromShare': true} : null);
    }
  }
}
