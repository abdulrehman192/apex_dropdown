/// Apex-quality dropdown widgets for Flutter.
///
/// Exports:
/// - `ApexDropdown<T>`: single-select dropdown with optional search
/// - `ApexMultiDropdown<T>`: multi-select dropdown with optional search + chips/count
/// - `ApexAsyncDropdown<T>`: async dropdown API (placeholder UI for now)
// ignore: unnecessary_library_name
library apex_dropdown;

export 'src/models/cache_policy.dart';
export 'src/models/chip_display.dart';
export 'src/models/decoration.dart';

export 'src/widgets/apex_async_dropdown.dart';
export 'src/widgets/apex_dropdown.dart';
export 'src/widgets/apex_multi_dropdown.dart';

export 'src/form_fields/apex_async_dropdown_form_field.dart';
export 'src/form_fields/apex_dropdown_form_field.dart';
export 'src/form_fields/apex_multi_dropdown_form_field.dart';
