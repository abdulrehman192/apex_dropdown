import 'package:flutter/material.dart';

import '../models/decoration.dart';
import '../models/selection_model.dart';
import '../utils/dropdown_utils.dart';
import '_apex_dropdown_field.dart';
import '_apex_dropdown_overlay.dart';

/// Single-select dropdown with an overlay list and optional in-overlay search.
///
/// The widget is controllerless: provide [value] and update it in [onChanged].
/// For model objects, provide [compareFn] so selection survives item refreshes.
class ApexDropdown<T> extends StatefulWidget {
  const ApexDropdown({
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.compareFn,
    this.hintText,
    this.enabled = true,
    this.decoration,
    this.itemBuilder,
    this.searchEnabled = false,
    this.searchHintText,
    this.searchMatcher,
    this.emptyResultsText = 'No Data Found',
    this.onOpenChanged,
    this.onDismissed,
    this.onInvalidValue,
    super.key,
  });

  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  final T? value;
  final bool Function(T a, T b)? compareFn;

  final String? hintText;
  final bool enabled;
  final ApexDropdownDecoration? decoration;
  final Widget Function(T item)? itemBuilder;

  final bool searchEnabled;
  final String? searchHintText;
  final bool Function(T item, String query)? searchMatcher;
  final String? emptyResultsText;

  final ValueChanged<bool>? onOpenChanged;
  final VoidCallback? onDismissed;
  final ValueChanged<T>? onInvalidValue;

  @override
  State<ApexDropdown<T>> createState() => _ApexDropdownState<T>();
}

class _ApexDropdownState<T> extends State<ApexDropdown<T>> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;
  bool _disposing = false;

  ApexSelectionModel<T> get _model => ApexSelectionModel<T>(
        items: widget.items,
        value: widget.value,
        compareFn: widget.compareFn,
      );

  @override
  void didUpdateWidget(covariant ApexDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final v = widget.value;
    if (v != null && !_model.containsValue(v)) {
      apexDebugInvalidValue(
        invalidValue: v,
        onInvalidValue: widget.onInvalidValue,
        context: 'ApexDropdown',
      );
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
      builder: (context) {
        return ApexDropdownOverlay<T>(
          link: _link,
          placement: placement,
          items: widget.items,
          itemLabel: _safeItemLabel,
          isSelected: (item) => _model.isSelected(item),
          onSelect: (item) {
            widget.onChanged(item);
            _close();
          },
          onDismiss: () => _close(),
          decoration: widget.decoration ?? const ApexDropdownDecoration(),
          searchEnabled: widget.searchEnabled,
          fieldWidth: fieldWidth,
          searchHintText: widget.searchHintText,
          searchMatcher: widget.searchMatcher,
          itemBuilder: widget.itemBuilder,
          emptyResultsText: widget.emptyResultsText,
        );
      },
    );

    overlay.insert(_entry!);
    setState(() => _open = true);
    widget.onOpenChanged?.call(true);
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
    if (notify) widget.onDismissed?.call();
  }

  void _toggle() {
    if (!widget.enabled) return;
    if (_open) {
      _close();
    } else {
      _openOverlay();
    }
  }

  String _safeItemLabel(T item) {
    try {
      return widget.itemLabel(item);
    } catch (e) {
      apexDebugLog('itemLabel threw: $e');
      return item.toString();
    }
  }

  @override
  void dispose() {
    _disposing = true;
    _close(notify: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _model.normalizeSingle();
    final v = widget.value;
    if (v != null && normalized == null) {
      apexDebugInvalidValue(
        invalidValue: v,
        onInvalidValue: widget.onInvalidValue,
        context: 'ApexDropdown.build',
      );
    }

    final text = normalized == null ? null : _safeItemLabel(normalized);

    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _close(notify: false);
      },
      child: ApexDropdownField(
        link: _link,
        text: text,
        hintText: widget.hintText,
        enabled: widget.enabled,
        isOpen: _open,
        onTap: _toggle,
        decoration: widget.decoration,
        containerKey: _fieldKey,
      ),
    );
  }
}

