/// How a multi-select dropdown displays the current selection in the closed field.
enum ApexDropdownChipDisplay {
  /// Render a compact single-line summary (e.g. comma-separated values).
  count,

  /// Render each selected value as a removable chip.
  chips,

  /// Render both a summary and chips.
  countAndChips,
}

