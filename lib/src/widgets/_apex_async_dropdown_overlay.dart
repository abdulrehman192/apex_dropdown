import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cache_policy.dart';
import '../models/decoration.dart';
import '../utils/dropdown_utils.dart';
import '_apex_dropdown_list.dart';

typedef ApexAsyncQueryFn<T> = Future<List<T>> Function(String query);

class _ApexAsyncCacheEntry<T> {
  _ApexAsyncCacheEntry(this.items, this.storedAt);

  final List<T> items;
  final DateTime storedAt;
}

/// Internal overlay implementation used by async dropdown widgets.
///
/// This is not exported from `package:apex_dropdown/apex_dropdown.dart`.
class ApexAsyncDropdownOverlay<T> extends StatefulWidget {
  const ApexAsyncDropdownOverlay({
    required this.link,
    required this.placement,
    required this.value,
    required this.values,
    required this.compareFn,
    required this.itemLabel,
    required this.queryFn,
    required this.onSelect,
    required this.onDismiss,
    required this.decoration,
    required this.fieldWidth,
    required this.debounce,
    required this.minQueryLength,
    required this.maxResults,
    required this.initialItems,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.emptyBuilder,
    required this.retryEnabled,
    required this.retryLabel,
    required this.cachePolicy,
    required this.cacheTtl,
    required this.multiSelect,
    super.key,
  });

  final LayerLink link;
  final ApexDropdownPlacement placement;
  final double? fieldWidth;
  final ApexDropdownDecoration decoration;

  /// Single-select value (when [multiSelect] is false).
  final T? value;

  /// Multi-select values (when [multiSelect] is true).
  final List<T> values;

  final bool Function(T a, T b)? compareFn;
  final String Function(T) itemLabel;

  final ApexAsyncQueryFn<T> queryFn;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;

  final Duration debounce;
  final int minQueryLength;
  final int? maxResults;
  final List<T> initialItems;

  final WidgetBuilder? loadingBuilder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool retryEnabled;
  final String retryLabel;

  final ApexDropdownCachePolicy cachePolicy;
  final Duration? cacheTtl;

  final bool multiSelect;

  @override
  State<ApexAsyncDropdownOverlay<T>> createState() =>
      _ApexAsyncDropdownOverlayState<T>();
}

class _ApexAsyncDropdownOverlayState<T>
    extends State<ApexAsyncDropdownOverlay<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  Timer? _debounceTimer;

  String _query = '';
  int _highlight = 0;
  bool _keyboardHighlightEnabled = false;

  int _requestId = 0;
  bool _loading = false;
  Object? _error;
  List<T> _items = const [];

  final Map<String, _ApexAsyncCacheEntry<T>> _cache = {};

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
  late final Animation<double> _scale = Tween<double>(begin: 0.95, end: 1)
      .chain(CurveTween(curve: Curves.easeOutCubic))
      .animate(_anim);

  bool _equals(T a, T b) {
    final fn = widget.compareFn;
    if (fn != null) return fn(a, b);
    return a == b;
  }

  bool _isSelected(T item) {
    if (widget.multiSelect) {
      for (final v in widget.values) {
        if (_equals(v, item)) return true;
      }
      return false;
    }
    final v = widget.value;
    if (v == null) return false;
    return _equals(v, item);
  }

  bool _cacheValid(_ApexAsyncCacheEntry<T> entry) {
    if (widget.cachePolicy != ApexDropdownCachePolicy.memoryWithTtl) {
      return true;
    }
    final ttl = widget.cacheTtl;
    if (ttl == null) return false;
    final age = DateTime.now().difference(entry.storedAt);
    return age <= ttl;
  }

  List<T>? _cacheGet(String q) {
    if (widget.cachePolicy == ApexDropdownCachePolicy.none) return null;
    final entry = _cache[q];
    if (entry == null) return null;
    if (!_cacheValid(entry)) {
      _cache.remove(q);
      return null;
    }
    return entry.items;
  }

  void _cachePut(String q, List<T> items) {
    if (widget.cachePolicy == ApexDropdownCachePolicy.none) return;
    _cache[q] = _ApexAsyncCacheEntry<T>(items, DateTime.now());
  }

  List<T> _applyMaxResults(List<T> items) {
    final max = widget.maxResults;
    if (max == null || max <= 0) return items;
    if (items.length <= max) return items;
    return items.take(max).toList(growable: false);
  }

  Future<void> _runQuery(String rawQuery) async {
    final q = rawQuery.trim();
    if (q.length < widget.minQueryLength) {
      setState(() {
        _loading = false;
        _error = null;
        _items = widget.initialItems;
        _highlight = 0;
        _keyboardHighlightEnabled = false;
      });
      return;
    }

    final cached = _cacheGet(q);
    if (cached != null) {
      setState(() {
        _loading = false;
        _error = null;
        _items = _applyMaxResults(cached);
        _highlight = 0;
        _keyboardHighlightEnabled = false;
      });
      return;
    }

    final myId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await widget.queryFn(q);
      if (!mounted || myId != _requestId) return;
      final normalized = _applyMaxResults(List<T>.from(results));
      _cachePut(q, normalized);
      setState(() {
        _loading = false;
        _error = null;
        _items = normalized;
        _highlight = 0;
        _keyboardHighlightEnabled = false;
      });
    } catch (e) {
      if (!mounted || myId != _requestId) return;
      setState(() {
        _loading = false;
        _error = e;
        _items = const [];
        _highlight = 0;
        _keyboardHighlightEnabled = false;
      });
    }
  }

  void _onSearchChanged(String v) {
    _query = v;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      if (!mounted) return;
      _runQuery(_query);
    });
  }

  void _retry() {
    _runQuery(_query);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }

    if (_loading || _error != null) return KeyEventResult.ignored;
    final items = _items;
    if (items.isEmpty) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _keyboardHighlightEnabled = true;
        _highlight = (_highlight + 1).clamp(0, items.length - 1);
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _keyboardHighlightEnabled = true;
        _highlight = (_highlight - 1).clamp(0, items.length - 1);
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onSelect(items[_highlight]);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
    _query = '';
    if (widget.minQueryLength == 0 && widget.initialItems.isEmpty) {
      // Load initial results on open if allowed and no seed list was provided.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _runQuery('');
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _search.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.decoration.resolved(Theme.of(context));
    final openAbove = widget.placement.openAbove;
    final panelMaxHeight = widget.placement.panelMaxHeight;
    final rowIndicator =
        widget.multiSelect ? d.multiIndicatorBuilder : d.singleIndicatorBuilder;

    final Widget body;
    if (_loading) {
      body = widget.loadingBuilder?.call(context) ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    } else if (_error != null) {
      final err = _error!;
      body = widget.errorBuilder?.call(
            err,
            widget.retryEnabled ? _retry : () {},
          ) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load results',
                    style: d.itemTextStyle?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (widget.retryEnabled)
                    OutlinedButton(
                      onPressed: _retry,
                      child: Text(widget.retryLabel),
                    ),
                ],
              ),
            ),
          );
    } else if (_items.isEmpty) {
      body = widget.emptyBuilder?.call(context) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No Data Found',
                style: d.itemTextStyle?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
    } else {
      body = ApexDropdownList<T>(
        items: _items,
        itemLabel: widget.itemLabel,
        isSelected: _isSelected,
        onSelect: widget.onSelect,
        decoration: d,
        indicatorBuilder: rowIndicator,
        indicatorTrailing: true,
        highlightIndex: (!_keyboardHighlightEnabled || _items.isEmpty)
            ? null
            : _highlight,
      );
    }

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
            targetAnchor: openAbove ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor: openAbove ? Alignment.bottomLeft : Alignment.topLeft,
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
                                  hintText: 'Search...',
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
                            Flexible(child: body),
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

