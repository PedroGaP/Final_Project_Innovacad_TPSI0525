import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

enum AppOverlayType { info, success, error }

class AppOverlay {
  static List _getToastErrorType(BuildContext ctx, AppOverlayType type) {
    List colors = [
      ctx.theme.colors.primary,
      ctx.theme.colors.primaryForeground,
    ];

    if (type == AppOverlayType.success) {
      colors = [Colors.green, ctx.theme.colors.errorForeground];
    }

    if (type == AppOverlayType.error) {
      colors = [ctx.theme.colors.error, ctx.theme.colors.errorForeground];
    }

    return colors;
  }

  static void showToast(
    BuildContext ctx, {
    required String title,
    String description = "",
    IconData? icon,
    AppOverlayType type = AppOverlayType.info,
  }) {
    final typography = ctx.theme.typography;

    showFToast(
      description: description.isNotEmpty ? Text(description) : null,
      context: ctx,
      alignment: FToastAlignment.topRight,
      title: Text(
        title,
        style: typography.sm.copyWith(
          color: _getToastErrorType(ctx, type).first,
        ),
      ),
      icon: icon != null ? Icon(icon) : null,
      duration: const Duration(seconds: 3),
      style: (style) => style.copyWith(),
    );
  }
}
