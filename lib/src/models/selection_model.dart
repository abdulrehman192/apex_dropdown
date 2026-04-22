class ApexSelectionModel<T> {
  const ApexSelectionModel({
    required this.items,
    required this.value,
    this.compareFn,
  });

  final List<T> items;
  final T? value;
  final bool Function(T a, T b)? compareFn;

  bool equals(T a, T b) {
    final fn = compareFn;
    if (fn != null) return fn(a, b);
    return a == b;
  }

  T? normalizeSingle() {
    final v = value;
    if (v == null) return null;
    for (final item in items) {
      if (equals(item, v)) return item;
    }
    return null;
  }

  bool isSelected(T item) {
    final v = value;
    if (v == null) return false;
    return equals(item, v);
  }

  /// Whether [item] appears in [values] using [equals].
  bool isSelectedInList(List<T> values, T item) {
    for (final v in values) {
      if (equals(v, item)) return true;
    }
    return false;
  }

  List<T> normalizeMulti(List<T> values) {
    if (values.isEmpty) return const [];
    final out = <T>[];
    for (final v in values) {
      for (final item in items) {
        if (equals(item, v)) {
          out.add(item);
          break;
        }
      }
    }
    return out;
  }

  bool containsValue(T v) {
    for (final item in items) {
      if (equals(item, v)) return true;
    }
    return false;
  }
}

