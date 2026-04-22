import 'package:flutter/material.dart';

import '../models/chip_display.dart';
import '../models/decoration.dart';
import '../models/selection_model.dart';
import '../utils/dropdown_utils.dart';
import '_apex_dropdown_overlay.dart';
import '_apex_multi_dropdown_field.dart';

/// Multi-select dropdown with the same overlay placement and search behavior as
/// [ApexDropdown], checkbox-style row indicators, and optional chip / count
/// summary on the closed field.
class ApexMultiDropdown<T> extends StatefulWidget {
  const ApexMultiDropdown({
    required this.items,
    required this.values,
    required this.onChanged,
    this.itemLabel,
    this.compareFn,
    this.maxSelection,
    this.onSelectionLimitReached,
    this.preserveStaleValues = false,
    this.hintText,
    this.enabled = true,
    this.decoration,
    this.chipDisplay = ApexDropdownChipDisplay.count,
    this.searchEnabled = false,
    this.searchHintText,
    this.searchMatcher,
    this.emptyResultsText = 'No Data Found',
    this.onOpenChanged,
    this.onDismissed,
    this.itemBuilder,
    this.onInvalidValue,
    super.key,
  });

  final List<T> items;
  final List<T> values;
  final ValueChanged<List<T>> onChanged;
  /// Converts an item to the string shown in chips/count and in the overlay.
  ///
  /// If omitted, the widget falls back to `item.toString()` (and uses an empty
  /// string for `null` items).
  final String Function(T)? itemLabel;

  final bool Function(T a, T b)? compareFn;
  final int? maxSelection;
  final VoidCallback? onSelectionLimitReached;

  /// When false, entries in [values] that are not in [items] are hidden in the
  /// field until the parent removes them. When true, stale entries remain
  /// visible (labels via [itemLabel]) so users can clear them with chips.
  final bool preserveStaleValues;

  final String? hintText;
  final bool enabled;
  final ApexDropdownDecoration? decoration;
  final ApexDropdownChipDisplay chipDisplay;

  final bool searchEnabled;
  final String? searchHintText;
  final bool Function(T item, String query)? searchMatcher;
  final String? emptyResultsText;

  final ValueChanged<bool>? onOpenChanged;
  final VoidCallback? onDismissed;
  final Widget Function(T item)? itemBuilder;
  final ValueChanged<T>? onInvalidValue;

  @override
  State<ApexMultiDropdown<T>> createState() => _ApexMultiDropdownState<T>();
}

class _ApexMultiDropdownState<T> extends State<ApexMultiDropdown<T>> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;
  bool _disposing = false;

  ApexSelectionModel<T> _model() => ApexSelectionModel<T>(
        items: widget.items,
        value: null,
        compareFn: widget.compareFn,
      );

  @override
  void initState() {
    super.initState();
    _logStaleIfAny();
  }

  @override
  void didUpdateWidget(covariant ApexMultiDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.values, widget.values) ||
        !identical(oldWidget.items, widget.items)) {
      _logStaleIfAny();
      _scheduleOverlayRebuild();
    }
  }

  void _scheduleOverlayRebuild() {
    if (!_open || _entry == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _open && _entry != null) {
        _entry!.markNeedsBuild();
      }
    });
  }

  void _logStaleIfAny() {
    final m = _model();
    for (final v in widget.values) {
      if (!m.containsValue(v)) {
        apexDebugInvalidValue<T>(
          invalidValue: v,
          onInvalidValue: widget.onInvalidValue,
          context: 'ApexMultiDropdown',
        );
      }
    }
  }

  void _openOverlay() {
    if (_open) return;
    final overlay = Overlay.of(context);
    final fieldWidth = apexFieldWidthFromKey(_fieldKey);
    final dec = widget.decoration ?? const ApexDropdownDecoration();
    final resolved = dec.resolved(Theme.of(context));
    final placement = apexPlacementFromFieldKey(
      context: context,
      fieldKey: _fieldKey,
      resolved: resolved,
    );

    _entry = OverlayEntry(
      builder: (ctx) {
        final m = _model();
        return ApexDropdownOverlay<T>(
          link: _link,
          placement: placement,
          items: widget.items,
          itemLabel: _safeItemLabel,
          isSelected: (item) => m.isSelectedInList(widget.values, item),
          onSelect: _onOverlayToggle,
          onDismiss: () => _close(),
          decoration: widget.decoration ?? const ApexDropdownDecoration(),
          searchEnabled: widget.searchEnabled,
          fieldWidth: fieldWidth,
          searchHintText: widget.searchHintText,
          searchMatcher: widget.searchMatcher,
          itemBuilder: widget.itemBuilder,
          emptyResultsText: widget.emptyResultsText,
          multiSelect: true,
        );
      },
    );

    overlay.insert(_entry!);
    setState(() => _open = true);
    widget.onOpenChanged?.call(true);
  }

  void _onOverlayToggle(T item) {
    final m = _model();
    final current = List<T>.from(widget.values);
    if (m.isSelectedInList(current, item)) {
      widget.onChanged(current.where((v) => !m.equals(v, item)).toList());
    } else {
      final max = widget.maxSelection;
      if (max != null && current.length >= max) {
        widget.onSelectionLimitReached?.call();
        return;
      }
      var canonical = item;
      for (final it in widget.items) {
        if (m.equals(it, item)) {
          canonical = it;
          break;
        }
      }
      if (m.isSelectedInList(current, canonical)) return;
      widget.onChanged([...current, canonical]);
    }
    _scheduleOverlayRebuild();
  }

  void _onRemoveChip(T item) {
    final m = _model();
    widget.onChanged(
      widget.values.where((v) => !m.equals(v, item)).toList(),
    );
    _scheduleOverlayRebuild();
  }

  void _close({bool notify = true}) {
    if (!_open) return;
    _entry?.remove();
    _entry = null;
    if (mounted && !_disposing) {
      setState(() => _open = false);
    } else {
      _open = false;
    }
    widget.onOpenChanged?.call(false);
    if (notify) {
      widget.onDismissed?.call();
    }
  }

  void _toggleOpen() {
    if (!widget.enabled) return;
    if (_open) {
      _close();
    } else {
      _openOverlay();
    }
  }

  String _safeItemLabel(T item) {
    if (item == null) return '';
    try {
      return (widget.itemLabel ?? (i) => i.toString())(item);
    } catch (e) {
      apexDebugLog('itemLabel threw: $e');
      return item.toString();
    }
  }

  List<T> _displayValues() {
    final m = _model();
    if (widget.preserveStaleValues) {
      return List<T>.from(widget.values);
    }
    return m.normalizeMulti(widget.values);
  }

  @override
  void dispose() {
    _disposing = true;
    _close(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _close(notify: false);
      },
      child: ApexMultiDropdownField<T>(
        link: _link,
        displayValues: _displayValues(),
        itemLabel: widget.itemLabel,
        chipDisplay: widget.chipDisplay,
        hintText: widget.hintText,
        enabled: widget.enabled,
        isOpen: _open,
        onTap: _toggleOpen,
        onRemove: _onRemoveChip,
        decoration: widget.decoration,
        containerKey: _fieldKey,
      ),
    );
  }
}
