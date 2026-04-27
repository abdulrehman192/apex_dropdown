import 'package:flutter/material.dart';

import '../models/cache_policy.dart';
import '../models/chip_display.dart';
import '../models/decoration.dart';
import '../utils/dropdown_utils.dart';
import '_apex_async_dropdown_overlay.dart';
import '_apex_multi_dropdown_field.dart';

/// Multi-select async dropdown.
///
/// Similar to [ApexMultiDropdown] but loads options using [queryFn]. Rows toggle
/// selection without closing the overlay.
class ApexAsyncMultiDropdown<T> extends StatefulWidget {
  const ApexAsyncMultiDropdown({
    this.itemLabel,
    required this.queryFn,
    required this.onChanged,
    this.values = const [],
    this.compareFn,
    this.maxSelection,
    this.onSelectionLimitReached,
    this.preserveStaleValues = false,
    this.initialItems = const [],
    this.debounce = const Duration(milliseconds: 300),
    this.minQueryLength = 0,
    this.maxResults,
    this.hintText,
    this.enabled = true,
    this.decoration,
    this.chipDisplay = ApexDropdownChipDisplay.count,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.retryEnabled = true,
    this.retryLabel = 'Retry',
    this.cachePolicy = ApexDropdownCachePolicy.memoryPerSession,
    this.cacheTtl,
    this.onOpenChanged,
    this.onDismissed,
    this.onInvalidValue,
    super.key,
  });

  final String Function(T)? itemLabel;

  /// Fetches options for the current search query.
  final Future<List<T>> Function(String query) queryFn;

  /// Called with the updated selection list after each toggle/remove.
  final ValueChanged<List<T>> onChanged;

  final List<T> values;

  /// Compares values for identity (recommended for model objects).
  final bool Function(T a, T b)? compareFn;

  final int? maxSelection;

  /// Called when the user attempts to select more than [maxSelection].
  final VoidCallback? onSelectionLimitReached;
  final bool preserveStaleValues;

  final List<T> initialItems;
  final Duration debounce;
  final int minQueryLength;
  final int? maxResults;

  final String? hintText;
  final bool enabled;
  final ApexDropdownDecoration? decoration;
  final ApexDropdownChipDisplay chipDisplay;

  final WidgetBuilder? loadingBuilder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool retryEnabled;
  final String retryLabel;

  final ApexDropdownCachePolicy cachePolicy;
  final Duration? cacheTtl;

  final ValueChanged<bool>? onOpenChanged;
  final VoidCallback? onDismissed;

  /// Debug callback for handling invalid values (kept for API compatibility).
  final ValueChanged<T>? onInvalidValue;

  @override
  State<ApexAsyncMultiDropdown<T>> createState() =>
      _ApexAsyncMultiDropdownState<T>();
}

class _ApexAsyncMultiDropdownState<T> extends State<ApexAsyncMultiDropdown<T>> {
  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;
  bool _disposing = false;

  String _safeItemLabel(T item) {
    if (item == null) return '';
    try {
      return (widget.itemLabel ?? (i) => i.toString())(item);
    } catch (e) {
      apexDebugLog('itemLabel threw: $e');
      return item.toString();
    }
  }

  void _scheduleOverlayRebuild() {
    if (!_open || _entry == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _open && _entry != null) _entry!.markNeedsBuild();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ApexAsyncMultiDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.values, widget.values)) {
      _scheduleOverlayRebuild();
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
        return ApexAsyncDropdownOverlay<T>(
          link: _link,
          placement: placement,
          fieldWidth: fieldWidth,
          decoration: widget.decoration ?? const ApexDropdownDecoration(),
          value: null,
          values: widget.values,
          compareFn: widget.compareFn,
          itemLabel: _safeItemLabel,
          queryFn: widget.queryFn,
          onSelect: _onOverlayToggle,
          onDismiss: () => _close(),
          debounce: widget.debounce,
          minQueryLength: widget.minQueryLength,
          maxResults: widget.maxResults,
          initialItems: widget.initialItems,
          loadingBuilder: widget.loadingBuilder,
          errorBuilder: widget.errorBuilder,
          emptyBuilder: widget.emptyBuilder,
          retryEnabled: widget.retryEnabled,
          retryLabel: widget.retryLabel,
          cachePolicy: widget.cachePolicy,
          cacheTtl: widget.cacheTtl,
          multiSelect: true,
        );
      },
    );

    overlay.insert(_entry!);
    setState(() => _open = true);
    widget.onOpenChanged?.call(true);
  }

  void _onOverlayToggle(T item) {
    final current = List<T>.from(widget.values);
    bool selected = false;
    for (final v in current) {
      final eq = widget.compareFn;
      if (eq != null ? eq(v, item) : v == item) {
        selected = true;
        break;
      }
    }
    if (selected) {
      widget.onChanged(
        current
            .where(
              (v) => !(widget.compareFn != null
                  ? widget.compareFn!(v, item)
                  : v == item),
            )
            .toList(),
      );
    } else {
      final max = widget.maxSelection;
      if (max != null && current.length >= max) {
        widget.onSelectionLimitReached?.call();
        return;
      }
      widget.onChanged([...current, item]);
    }
    _scheduleOverlayRebuild();
  }

  void _onRemoveChip(T item) {
    widget.onChanged(
      widget.values
          .where(
            (v) => !(widget.compareFn != null
                ? widget.compareFn!(v, item)
                : v == item),
          )
          .toList(),
    );
    _scheduleOverlayRebuild();
  }

  List<T> _displayValues() {
    if (widget.preserveStaleValues) return List<T>.from(widget.values);
    // In async mode, we cannot reliably normalize against the latest remote
    // option list, so we preserve the provided values.
    return List<T>.from(widget.values);
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
        onTap: _toggle,
        onRemove: _onRemoveChip,
        decoration: widget.decoration,
        containerKey: _fieldKey,
      ),
    );
  }
}

