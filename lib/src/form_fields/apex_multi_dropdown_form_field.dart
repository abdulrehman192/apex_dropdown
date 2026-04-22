import 'package:flutter/material.dart';

import '../models/chip_display.dart';
import '../models/decoration.dart';
import '../widgets/apex_multi_dropdown.dart';
import '_merge_form_field_decoration.dart';

/// A `FormField<List<T>>` wrapper around [ApexMultiDropdown].
///
/// Use this when integrating multi-select with `Form`, `validator`, and `onSaved`.
class ApexMultiDropdownFormField<T> extends FormField<List<T>> {
  ApexMultiDropdownFormField({
    required List<T> items,
    required List<T> values,
    required ValueChanged<List<T>> onChanged,
    String Function(T)? itemLabel,
    bool Function(T a, T b)? compareFn,
    int? maxSelection,
    VoidCallback? onSelectionLimitReached,
    bool preserveStaleValues = false,
    String? hintText,
    bool enabled = true,
    ApexDropdownDecoration? decoration,
    TextStyle? fieldTextStyle,
    TextStyle? itemTextStyle,
    ApexDropdownChipDisplay chipDisplay = ApexDropdownChipDisplay.count,
    bool searchEnabled = false,
    String? searchHintText,
    bool Function(T item, String query)? searchMatcher,
    String? emptyResultsText,
    Widget Function(T item)? itemBuilder,
    ValueChanged<T>? onInvalidValue,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onDismissed,
    super.onSaved,
    super.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    super.key,
  }) : super(
          initialValue: values,
          autovalidateMode: autovalidateMode,
          builder: (state) {
            final effectiveDecoration = mergeFormFieldDecoration(
              decoration,
              fieldTextStyle,
              itemTextStyle,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApexMultiDropdown<T>(
                  items: items,
                  values: state.value ?? const [],
                  compareFn: compareFn,
                  maxSelection: maxSelection,
                  onSelectionLimitReached: onSelectionLimitReached,
                  preserveStaleValues: preserveStaleValues,
                  hintText: hintText,
                  enabled: enabled,
                  decoration: effectiveDecoration,
                  chipDisplay: chipDisplay,
                  searchEnabled: searchEnabled,
                  searchHintText: searchHintText,
                  searchMatcher: searchMatcher,
                  emptyResultsText: emptyResultsText,
                  itemBuilder: itemBuilder,
                  onInvalidValue: onInvalidValue,
                  onOpenChanged: onOpenChanged,
                  onDismissed: onDismissed,
                  itemLabel: itemLabel,
                  onChanged: (list) {
                    state.didChange(list);
                    onChanged(list);
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      state.errorText ?? '',
                      style: TextStyle(
                        color: Theme.of(state.context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
