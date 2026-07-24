import 'dart:ui';

import 'package:flutter/material.dart';

extension WidgetExtension on Widget? {
  Padding paddingAll(double padding) {
    return Padding(padding: EdgeInsets.all(padding), child: this);
  }

  Padding paddingOnly({double top = 0.0, double left = 0.0, double bottom = 0.0, double right = 0.0}) {
    return Padding(padding: EdgeInsets.fromLTRB(left, top, right, bottom), child: this);
  }

  Padding paddingSymmetric({double vertical = 0.0, double horizontal = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }
}
