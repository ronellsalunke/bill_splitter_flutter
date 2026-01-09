import 'package:bs_flutter/app/res/app_colors.dart';
import 'package:flutter/material.dart';

Widget verticalSpace(double height) => SizedBox(height: height);

Widget horizontalSpace(double width) => SizedBox(width: width);

Widget line({double width = 0.0, double height = 1, Color color = AppColors.dividerColor}) =>
    Container(width: width, height: height, color: color);
