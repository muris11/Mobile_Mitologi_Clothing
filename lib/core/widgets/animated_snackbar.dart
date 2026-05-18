import 'package:flutter/material.dart';

enum SnackbarType { info, success, error }

class AnimatedSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    SnackbarType type = SnackbarType.info,
  }) {
    final color = switch (type) {
      SnackbarType.success => Colors.green,
      SnackbarType.error => Colors.red,
      SnackbarType.info => Colors.blueGrey,
    };

    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      action: actionLabel != null
          ? SnackBarAction(label: actionLabel, onPressed: onAction ?? () {})
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.error);
  }
}
