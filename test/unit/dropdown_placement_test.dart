import 'package:apex_dropdown/src/utils/dropdown_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MediaQueryData mq({
    Size size = const Size(400, 800),
    EdgeInsets padding = const EdgeInsets.fromLTRB(0, 44, 0, 34),
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return MediaQueryData(
      size: size,
      padding: padding,
      viewInsets: viewInsets,
      devicePixelRatio: 1,
      textScaler: TextScaler.noScaling,
      platformBrightness: Brightness.light,
      viewPadding: padding,
    );
  }

  test('prefers below when full overlay height fits under the field', () {
    final p = computeApexDropdownPlacement(
      fieldGlobalRect: const Rect.fromLTWH(20, 120, 280, 48),
      media: mq(),
      overlayMaxHeight: 300,
      overlayOffset: const Offset(0, 6),
    );
    expect(p.openAbove, isFalse);
    expect(p.panelMaxHeight, 300);
  });

  test('opens above when bottom is cramped but top has room', () {
    final p = computeApexDropdownPlacement(
      fieldGlobalRect: const Rect.fromLTWH(20, 720, 280, 48),
      media: mq(),
      overlayMaxHeight: 300,
      overlayOffset: const Offset(0, 6),
    );
    expect(p.openAbove, isTrue);
    expect(p.panelMaxHeight, 300);
  });

  test('shrinks panel when opening below but only partial height remains', () {
    final p = computeApexDropdownPlacement(
      fieldGlobalRect: const Rect.fromLTWH(0, 200, 300, 48),
      media: mq(size: const Size(400, 500)),
      overlayMaxHeight: 300,
      overlayOffset: const Offset(0, 6),
    );
    expect(p.openAbove, isFalse);
    expect(p.panelMaxHeight, lessThan(300));
    expect(p.panelMaxHeight, greaterThan(0));
  });

  test('keyboard can flip placement from below to above', () {
    final withoutKeyboard = computeApexDropdownPlacement(
      fieldGlobalRect: const Rect.fromLTWH(0, 300, 300, 48),
      media: mq(),
      overlayMaxHeight: 300,
      overlayOffset: const Offset(0, 6),
    );
    final withKeyboard = computeApexDropdownPlacement(
      fieldGlobalRect: const Rect.fromLTWH(0, 300, 300, 48),
      media: mq(viewInsets: const EdgeInsets.only(bottom: 280)),
      overlayMaxHeight: 300,
      overlayOffset: const Offset(0, 6),
    );
    expect(withoutKeyboard.openAbove, isFalse);
    expect(withKeyboard.openAbove, isTrue);
    expect(withKeyboard.panelMaxHeight, lessThanOrEqualTo(250));
  });
}
