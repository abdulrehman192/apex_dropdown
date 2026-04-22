import 'package:flutter/material.dart';

import '../models/decoration.dart';

/// Merges optional [fieldTextStyle] / [itemTextStyle] into [decoration] for form fields.
ApexDropdownDecoration? mergeFormFieldDecoration(
  ApexDropdownDecoration? decoration,
  TextStyle? fieldTextStyle,
  TextStyle? itemTextStyle,
) {
  if (fieldTextStyle == null && itemTextStyle == null) {
    return decoration;
  }
  return (decoration ?? const ApexDropdownDecoration()).copyWith(
    textStyle: fieldTextStyle ?? decoration?.textStyle,
    itemTextStyle: itemTextStyle ?? decoration?.itemTextStyle,
  );
}
