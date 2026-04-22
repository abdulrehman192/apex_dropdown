import 'package:flutter/material.dart';

import '../widgets/apex_async_dropdown.dart';

class ApexAsyncDropdownFormField<T> extends FormField<T> {
  ApexAsyncDropdownFormField({
    required ApexAsyncDropdown<T> dropdown,
    super.onSaved,
    super.validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    super.key,
  }) : super(
          initialValue: dropdown.value,
          autovalidateMode: autovalidateMode,
          builder: (state) {
            return dropdown;
          },
        );
}

