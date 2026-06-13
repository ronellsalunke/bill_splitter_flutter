import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin ScrollRevealFabMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollRevealController;
  bool showScrollRevealFab = true;

  void initScrollRevealController() {
    scrollRevealController = ScrollController()..addListener(_handleScrollReveal);
  }

  void disposeScrollRevealController() {
    scrollRevealController
      ..removeListener(_handleScrollReveal)
      ..dispose();
  }

  Widget buildScrollRevealFab({required Widget child}) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      offset: showScrollRevealFab ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: showScrollRevealFab ? 1 : 0,
        child: IgnorePointer(ignoring: !showScrollRevealFab, child: child),
      ),
    );
  }

  void _handleScrollReveal() {
    if (!scrollRevealController.hasClients) {
      return;
    }

    final direction = scrollRevealController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && showScrollRevealFab) {
      _setFabVisibility(false);
    } else if ((direction == ScrollDirection.forward || scrollRevealController.offset <= 0) && !showScrollRevealFab) {
      _setFabVisibility(true);
    }
  }

  void _setFabVisibility(bool isVisible) {
    if (!mounted || showScrollRevealFab == isVisible) {
      return;
    }

    setState(() => showScrollRevealFab = isVisible);
  }
}
