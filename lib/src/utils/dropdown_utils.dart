import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/decoration.dart';

/// Vertical placement and height for the dropdown panel, computed from the
/// field position and [MediaQuery].
class ApexDropdownPlacement {
  const ApexDropdownPlacement({
    required this.openAbove,
    required this.panelMaxHeight,
  });

  /// When true, the panel is anchored to the top of the field (opens upward).
  final bool openAbove;

  /// Max height for the entire panel (search + list), clamped to viewport.
  final double panelMaxHeight;
}

/// [fieldGlobalRect] is the field's bounds in global coordinates.
ApexDropdownPlacement computeApexDropdownPlacement({
  required Rect fieldGlobalRect,
  required MediaQueryData media,
  required double overlayMaxHeight,
  required Offset overlayOffset,
}) {
  final gapY = overlayOffset.dy.abs();
  final topBound = media.padding.top;
  final bottomBound =
      media.size.height - media.viewInsets.bottom - media.padding.bottom;

  final spaceBelow = bottomBound - fieldGlobalRect.bottom - gapY;
  final spaceAbove = fieldGlobalRect.top - topBound - gapY;

  final needed = overlayMaxHeight;

  final bool openAbove;
  if (spaceBelow >= needed) {
    openAbove = false;
  } else if (spaceAbove >= needed) {
    openAbove = true;
  } else {
    openAbove = spaceAbove > spaceBelow;
  }

  final rawAvail = openAbove ? spaceAbove : spaceBelow;
  final avail = math.max(0.0, rawAvail);
  final panelMaxHeight = avail <= 0
      ? overlayMaxHeight
      : math.min(overlayMaxHeight, avail);

  return ApexDropdownPlacement(
    openAbove: openAbove,
    panelMaxHeight: panelMaxHeight,
  );
}

/// Placement for an overlay anchored to the widget identified by [fieldKey].
ApexDropdownPlacement apexPlacementFromFieldKey({
  required BuildContext context,
  required GlobalKey fieldKey,
  required ApexDropdownDecoration resolved,
}) {
  final fieldCtx = fieldKey.currentContext;
  if (fieldCtx == null) {
    return ApexDropdownPlacement(
      openAbove: false,
      panelMaxHeight: resolved.overlayMaxHeight,
    );
  }
  final ro = fieldCtx.findRenderObject();
  if (ro is! RenderBox || !ro.hasSize) {
    return ApexDropdownPlacement(
      openAbove: false,
      panelMaxHeight: resolved.overlayMaxHeight,
    );
  }
  final rect = ro.localToGlobal(Offset.zero) & ro.size;
  return computeApexDropdownPlacement(
    fieldGlobalRect: rect,
    media: MediaQuery.of(context),
    overlayMaxHeight: resolved.overlayMaxHeight,
    overlayOffset: resolved.overlayOffset,
  );
}

double? apexFieldWidthFromKey(GlobalKey fieldKey) {
  final ctx = fieldKey.currentContext;
  if (ctx == null) return null;
  final box = ctx.findRenderObject();
  if (box is RenderBox && box.hasSize) return box.size.width;
  return null;
}

T? apexFirstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

void apexDebugLog(String message) {
  if (!kDebugMode) return;
  // ignore: avoid_print
  print('[apex_dropdown] $message');
}

void apexDebugInvalidValue<T>({
  required T invalidValue,
  ValueChanged<T>? onInvalidValue,
  required String context,
}) {
  if (!kDebugMode) return;
  apexDebugLog('$context: value not found in items. value=$invalidValue');
  try {
    onInvalidValue?.call(invalidValue);
  } catch (e) {
    apexDebugLog('onInvalidValue threw: $e');
  }
}

