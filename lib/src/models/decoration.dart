import 'package:flutter/material.dart';

typedef ApexIndicatorBuilder = Widget Function(
  BuildContext context,
  bool selected,
);

/// Visual configuration for dropdown fields and their overlay lists.
///
/// Pass an instance to `decoration:` on `ApexDropdown` / `ApexMultiDropdown` (or
/// their form field variants) to customize colors, typography, padding, and
/// overlay geometry.
class ApexDropdownDecoration {
  const ApexDropdownDecoration({
    this.borderColor,
    this.focusedBorderColor,
    this.disabledBorderColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.fillColor,
    this.hoverColor,
    /// Selected value and hint on the closed field.
    this.textStyle,
    this.hintStyle,
    /// Inner padding of the closed field.
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    /// Fixed height for the closed field.
    ///
    /// Defaults to 48 to match common Material input sizing.
    this.fieldHeight = 48,
    /// Text style for each row label in the overlay list (defaults from theme).
    this.itemTextStyle,
    /// Horizontal and vertical padding for overlay list rows.
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    /// Background for the row that matches the current value.
    this.selectedItemBackgroundColor,
    /// Background for the keyboard-highlighted row (arrow keys).
    this.keyboardHighlightBackgroundColor,
    this.overlayMaxHeight = 300,
    this.overlayElevation = 6,
    this.overlayBorderRadius,
    this.matchFieldWidth = true,
    this.overlayOffset = const Offset(0, 6),
    this.singleIndicatorBuilder,
    this.multiIndicatorBuilder,
  });

  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? disabledBorderColor;
  final BorderRadius borderRadius;

  final Color? fillColor;
  final Color? hoverColor;

  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  final EdgeInsets padding;
  final double? fieldHeight;

  final TextStyle? itemTextStyle;
  final EdgeInsets itemPadding;
  final Color? selectedItemBackgroundColor;
  final Color? keyboardHighlightBackgroundColor;

  final double overlayMaxHeight;
  final double overlayElevation;
  final BorderRadius? overlayBorderRadius;
  final bool matchFieldWidth;
  final Offset overlayOffset;
  final ApexIndicatorBuilder? singleIndicatorBuilder;
  final ApexIndicatorBuilder? multiIndicatorBuilder;

  ApexDropdownDecoration resolved(ThemeData theme) {
    final cs = theme.colorScheme;
    final baseTextStyle =
        (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(fontSize: 16);
    return ApexDropdownDecoration(
      borderColor: borderColor ?? cs.outlineVariant,
      focusedBorderColor: focusedBorderColor ?? cs.primary,
      disabledBorderColor:
          disabledBorderColor ?? cs.outlineVariant.withValues(alpha: 0.5),
      borderRadius: borderRadius,
      fillColor: fillColor ?? Colors.white,
      hoverColor: hoverColor ?? cs.surfaceContainerHighest.withValues(alpha: 0.35),
      textStyle: textStyle ?? baseTextStyle,
      hintStyle: hintStyle ?? baseTextStyle.copyWith(color: theme.hintColor),
      padding: padding,
      fieldHeight: fieldHeight,
      itemTextStyle: itemTextStyle ?? baseTextStyle,
      itemPadding: itemPadding,
      selectedItemBackgroundColor: selectedItemBackgroundColor ??
          cs.primary.withValues(alpha: 0.10),
      keyboardHighlightBackgroundColor: keyboardHighlightBackgroundColor ??
          cs.surfaceContainerHighest,
      overlayMaxHeight: overlayMaxHeight,
      overlayElevation: overlayElevation,
      overlayBorderRadius: overlayBorderRadius ?? borderRadius,
      matchFieldWidth: matchFieldWidth,
      overlayOffset: overlayOffset,
      singleIndicatorBuilder: singleIndicatorBuilder ??
          (context, selected) => Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 22,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
      multiIndicatorBuilder: multiIndicatorBuilder ??
          (context, selected) => Icon(
                selected ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                size: 22,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
    );
  }

  static const Object _fieldHeightSentinel = Object();

  ApexDropdownDecoration copyWith({
    Color? borderColor,
    Color? focusedBorderColor,
    Color? disabledBorderColor,
    BorderRadius? borderRadius,
    Color? fillColor,
    Color? hoverColor,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    TextStyle? itemTextStyle,
    EdgeInsets? padding,
    EdgeInsets? itemPadding,
    Object? fieldHeight = _fieldHeightSentinel,
    Color? selectedItemBackgroundColor,
    Color? keyboardHighlightBackgroundColor,
    double? overlayMaxHeight,
    double? overlayElevation,
    BorderRadius? overlayBorderRadius,
    bool? matchFieldWidth,
    Offset? overlayOffset,
    ApexIndicatorBuilder? singleIndicatorBuilder,
    ApexIndicatorBuilder? multiIndicatorBuilder,
  }) {
    return ApexDropdownDecoration(
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      fillColor: fillColor ?? this.fillColor,
      hoverColor: hoverColor ?? this.hoverColor,
      textStyle: textStyle ?? this.textStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      itemTextStyle: itemTextStyle ?? this.itemTextStyle,
      padding: padding ?? this.padding,
      itemPadding: itemPadding ?? this.itemPadding,
      fieldHeight: fieldHeight == _fieldHeightSentinel
          ? this.fieldHeight
          : fieldHeight as double?,
      selectedItemBackgroundColor:
          selectedItemBackgroundColor ?? this.selectedItemBackgroundColor,
      keyboardHighlightBackgroundColor: keyboardHighlightBackgroundColor ??
          this.keyboardHighlightBackgroundColor,
      overlayMaxHeight: overlayMaxHeight ?? this.overlayMaxHeight,
      overlayElevation: overlayElevation ?? this.overlayElevation,
      overlayBorderRadius: overlayBorderRadius ?? this.overlayBorderRadius,
      matchFieldWidth: matchFieldWidth ?? this.matchFieldWidth,
      overlayOffset: overlayOffset ?? this.overlayOffset,
      singleIndicatorBuilder: singleIndicatorBuilder ?? this.singleIndicatorBuilder,
      multiIndicatorBuilder: multiIndicatorBuilder ?? this.multiIndicatorBuilder,
    );
  }
}
