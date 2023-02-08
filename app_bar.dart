import 'package:flutter/material.dart';
import '../core/themes/app_themes.dart';

AppBar appBarWidget(
  BuildContext context, {
  required String title,
  List<Widget>? actions,
  Color? backgroundColor,
  Widget? flexibleSpace,
  PreferredSize? bottom,
}) {
  return AppBar(
    title: Text(title),
    backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
    flexibleSpace: flexibleSpace ??
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppThemes.primaryColor,
                AppThemes.secondaryColor,
              ],
            ),
          ),
        ),
    actions: actions,
    bottom: bottom,
  );
}
