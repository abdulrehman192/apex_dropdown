import 'package:flutter/material.dart';

import '../widgets/apex_async_multi_dropdown.dart';

/// A `FormField<List<T>>` wrapper around [ApexAsyncMultiDropdown].
class ApexAsyncMultiDropdownFormField<T> extends FormField<List<T>> {
  ApexAsyncMultiDropdownFormField({
    required ApexAsyncMultiDropdown<T> dropdown,
    super.onSaved,
    super.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    super.key,
  }) : super(
          initialValue: dropdown.values,
          autovalidateMode: autovalidateMode,
          builder: (state) => dropdown,
        );
}

