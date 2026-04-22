import 'package:flutter/material.dart';

import '../models/decoration.dart';
import '../widgets/apex_dropdown.dart';
import '_merge_form_field_decoration.dart';

/// A `FormField<T>` wrapper around [ApexDropdown].
///
/// Use this when integrating with `Form`, `validator`, and `onSaved`.
class ApexDropdownFormField<T> extends FormField<T> {
  ApexDropdownFormField({
    required List<T> items,
    String Function(T)? itemLabel,
    required ValueChanged<T?> onChanged,
    T? value,
    bool Function(T a, T b)? compareFn,
    String? hintText,
    bool enabled = true,
    ApexDropdownDecoration? decoration,
    /// Overrides [ApexDropdownDecoration.textStyle] on the closed field.
    TextStyle? fieldTextStyle,
    /// Overrides [ApexDropdownDecoration.itemTextStyle] for overlay item labels.
    TextStyle? itemTextStyle,
    Widget Function(T item)? itemBuilder,
    bool searchEnabled = false,
    String? searchHintText,
    bool Function(T item, String query)? searchMatcher,
    String? emptyResultsText,
    super.onSaved,
    super.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    super.key,
  }) : super(
          initialValue: value,
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
                ApexDropdown<T>(
                  items: items,
                  itemLabel: itemLabel,
                  value: state.value,
                  compareFn: compareFn,
                  hintText: hintText,
                  enabled: enabled,
                  decoration: effectiveDecoration,
                  itemBuilder: itemBuilder,
                  searchEnabled: searchEnabled,
                  searchHintText: searchHintText,
                  searchMatcher: searchMatcher,
                  emptyResultsText: emptyResultsText,
                  onChanged: (v) {
                    state.didChange(v);
                    onChanged(v);
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

