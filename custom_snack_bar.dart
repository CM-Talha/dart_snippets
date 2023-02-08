import 'package:flutter/material.dart';

enum SnackBarType { info, error, success }

showSnackBar(
    BuildContext context, {
      required final SnackBarType type,
      final String? message,
      final SnackBarAction? action,
      final VoidCallback? onVisible,
      final Duration? duration,
    }) {
  ScaffoldMessenger.of(context).showSnackBar(customSnackBar(context,
      type: type,
      message: message,
      action: action,
      onVisible: onVisible,
      duration: duration));
}

SnackBar customSnackBar(
    BuildContext context, {
      final SnackBarAction? action,
      required final SnackBarType type,
      final String? message,
      final VoidCallback? onVisible,
      final Duration? duration,
    }) {
  return SnackBar(
    action: action,
    margin: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
    padding: EdgeInsets.zero,
    content: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      leading: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: getIcon(type)),
      style: ListTileStyle.drawer,
      tileColor: Colors.black54,
      title: Text(
        getTitle(type),
        style: TextStyle(
          color: getColor(type),
        ),
      ),
      subtitle: Text(
        message ?? "Unknown Error Occurred, Please Try Again Late",
        style: const TextStyle(color: Colors.white),
      ),
    ),
    duration: duration ?? const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.black54,
    elevation: 8,
    onVisible: onVisible,
  );
}

String getTitle(SnackBarType type) {
  switch (type) {
    case SnackBarType.error:
      return "Error";
    case SnackBarType.info:
      return "Info";
    case SnackBarType.success:
      return "Success";
    default:
      return "Error";
  }
}

Color getColor(SnackBarType type) {
  switch (type) {
    case SnackBarType.error:
      return Colors.red.shade900;
    case SnackBarType.info:
      return Colors.blue.shade800;
    case SnackBarType.success:
      return const Color.fromARGB(255, 0, 170, 11);
    default:
      return Colors.red.shade900;
  }
}

Icon getIcon(SnackBarType type) {
  switch (type) {
    case SnackBarType.error:
      return Icon(
        Icons.cancel,
        color: Colors.red.shade900,
      );
    case SnackBarType.info:
      return Icon(
        Icons.info,
        color: Colors.blue.shade800,
      );
    case SnackBarType.success:
      return const Icon(
        Icons.check,
        color: Color.fromARGB(255, 0, 170, 11),
      );
    default:
      return Icon(
        Icons.cancel,
        color: Colors.red.shade900,
      );
  }
}