import 'package:flutter/material.dart';

import '../models/cache_policy.dart';
import '../models/decoration.dart';

class ApexAsyncDropdown<T> extends StatelessWidget {
  const ApexAsyncDropdown({
    required this.itemLabel,
    required this.queryFn,
    required this.onChanged,
    this.value,
    this.compareFn,
    this.initialItems = const [],
    this.debounce = const Duration(milliseconds: 300),
    this.minQueryLength = 0,
    this.maxResults,
    this.hintText,
    this.enabled = true,
    this.decoration,
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

  final String Function(T) itemLabel;
  final Future<List<T>> Function(String query) queryFn;
  final ValueChanged<T?> onChanged;

  final T? value;
  final bool Function(T a, T b)? compareFn;

  final List<T> initialItems;
  final Duration debounce;
  final int minQueryLength;
  final int? maxResults;

  final String? hintText;
  final bool enabled;
  final ApexDropdownDecoration? decoration;

  final WidgetBuilder? loadingBuilder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool retryEnabled;
  final String retryLabel;

  final ApexDropdownCachePolicy cachePolicy;
  final Duration? cacheTtl;

  final ValueChanged<bool>? onOpenChanged;
  final VoidCallback? onDismissed;
  final ValueChanged<T>? onInvalidValue;

  @override
  Widget build(BuildContext context) {
    // TODO: full implementation (debounce, last-query-wins, cache, lifecycle safety).
    // Stub kept compiling so single-select can ship first.
    return AbsorbPointer(
      absorbing: true,
      child: Opacity(
        opacity: 0.65,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(hintText ?? 'ApexAsyncDropdown (coming soon)'),
        ),
      ),
    );
  }
}

