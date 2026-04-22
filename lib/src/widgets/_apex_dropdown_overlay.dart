import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/decoration.dart';
import '../utils/dropdown_utils.dart';
import '_apex_dropdown_list.dart';

class ApexDropdownOverlay<T> extends StatefulWidget {
  const ApexDropdownOverlay({
    required this.link,
    required this.placement,
    required this.items,
    required this.itemLabel,
    required this.isSelected,
    required this.onSelect,
    required this.onDismiss,
    required this.decoration,
    required this.searchEnabled,
    required this.fieldWidth,
    this.searchHintText,
    this.searchMatcher,
    this.itemBuilder,
    this.emptyResultsText,
    this.multiSelect = false,
    super.key,
  });

  final LayerLink link;
  final ApexDropdownPlacement placement;
  final List<T> items;
  final String Function(T) itemLabel;
  final bool Function(T) isSelected;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;
  final ApexDropdownDecoration decoration;
  final double? fieldWidth;

  final bool searchEnabled;
  final String? searchHintText;
  final bool Function(T item, String query)? searchMatcher;
  final Widget Function(T item)? itemBuilder;
  final String? emptyResultsText;

  /// When true, list rows use [ApexDropdownDecoration.multiIndicatorBuilder]
  /// (e.g. checkboxes); when false, [singleIndicatorBuilder] (radio-style).
  final bool multiSelect;

  @override
  State<ApexDropdownOverlay<T>> createState() => _ApexDropdownOverlayState<T>();
}

class _ApexDropdownOverlayState<T> extends State<ApexDropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  String _query = '';
  int _highlight = 0;
  bool _keyboardHighlightEnabled = false;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  late final Animation<double> _scale = Tween<double>(begin: 0.95, end: 1)
      .chain(CurveTween(curve: Curves.easeOutCubic))
      .animate(_anim);

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _anim.dispose();
    super.dispose();
  }

  String _safeLabel(T item) {
    try {
      return widget.itemLabel(item);
    } catch (_) {
      return item.toString();
    }
  }

  List<T> _filtered() {
    final q = _query.trim();
    if (!widget.searchEnabled || q.isEmpty) return widget.items;

    final matcher = widget.searchMatcher ??
        (T item, String query) {
          // Allow models to provide their own filtering (e.g. `bool filter(String)`),
          // without taking a dependency on a specific interface/package.
          try {
            final dynamic any = item;
            final dynamic result = any.filter(query);
            if (result is bool) return result;
          } catch (_) {}
          return _safeLabel(item).toLowerCase().contains(query.toLowerCase());
        };

    return widget.items.where((item) => matcher(item, q)).toList();
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _query = v;
        _highlight = 0;
        _keyboardHighlightEnabled = false;
      });
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final items = _filtered();

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (items.isNotEmpty) {
        setState(() {
          _keyboardHighlightEnabled = true;
          _highlight = (_highlight + 1).clamp(0, items.length - 1);
        });
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (items.isNotEmpty) {
        setState(() {
          _keyboardHighlightEnabled = true;
          _highlight = (_highlight - 1).clamp(0, items.length - 1);
        });
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (items.isNotEmpty) widget.onSelect(items[_highlight]);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.decoration.resolved(Theme.of(context));
    final items = _filtered();
    final openAbove = widget.placement.openAbove;
    final panelMaxHeight = widget.placement.panelMaxHeight;
    final rowIndicator = widget.multiSelect
        ? d.multiIndicatorBuilder
        : d.singleIndicatorBuilder;

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onDismiss,
            ),
          ),
          CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            targetAnchor:
                openAbove ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                openAbove ? Alignment.bottomLeft : Alignment.topLeft,
            offset: openAbove
                ? Offset(d.overlayOffset.dx, -d.overlayOffset.dy)
                : d.overlayOffset,
            child: Material(
              color: Colors.transparent,
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: SizedBox(
                    width: (d.matchFieldWidth ? widget.fieldWidth : null),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: panelMaxHeight),
                      child: Material(
                        elevation: d.overlayElevation,
                        color: d.fillColor ?? Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: d.overlayBorderRadius ?? d.borderRadius,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.searchEnabled)
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  d.itemPadding.left,
                                  8,
                                  d.itemPadding.right,
                                  8,
                                ),
                                child: TextField(
                                  controller: _search,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    prefixIcon: const Icon(Icons.search),
                                    hintText:
                                        widget.searchHintText ?? 'Search...',
                                    suffixIcon: _search.text.isEmpty
                                        ? null
                                        : IconButton(
                                            onPressed: () {
                                              _search.clear();
                                              _onSearchChanged('');
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: _onSearchChanged,
                                ),
                              ),
                            Flexible(
                              child: ApexDropdownList<T>(
                                items: items,
                                itemLabel: widget.itemLabel,
                                itemBuilder: widget.itemBuilder,
                                isSelected: widget.isSelected,
                                onSelect: widget.onSelect,
                                decoration: d,
                                indicatorBuilder: rowIndicator,
                                indicatorTrailing: true,
                                highlightIndex:
                                    (!_keyboardHighlightEnabled || items.isEmpty)
                                        ? null
                                        : _highlight,
                                emptyResultsText: widget.emptyResultsText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

