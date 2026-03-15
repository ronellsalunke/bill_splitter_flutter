import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Clickable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onClick;
  final int debounceMs;

  const Clickable({super.key, required this.child, required this.onClick, this.debounceMs = 250});

  @override
  State<Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  Timer? _timer;

  void _handleTap() {
    if (_timer?.isActive ?? false) return; // leading-edge debounce
    HapticFeedback.selectionClick();
    print('click');
    widget.onClick?.call();
    _timer = Timer(Duration(milliseconds: widget.debounceMs), () {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onClick != null ? _handleTap : null,
      child: widget.child,
    );
  }
}
