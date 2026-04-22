import 'package:flutter/material.dart';

import '../models/decoration.dart';

class ApexDropdownList<T> extends StatelessWidget {
  const ApexDropdownList({
    required this.items,
    required this.itemLabel,
    required this.isSelected,
    required this.onSelect,
    required this.decoration,
    this.indicatorBuilder,
    this.indicatorTrailing = true,
    this.itemBuilder,
    this.enabled = true,
    this.highlightIndex,
    this.emptyResultsText,
    super.key,
  });

  final List<T> items;
  final String Function(T) itemLabel;
  final bool Function(T) isSelected;
  final ValueChanged<T> onSelect;
  final ApexDropdownDecoration decoration;
  final ApexIndicatorBuilder? indicatorBuilder;
  final bool indicatorTrailing;
  final Widget Function(T item)? itemBuilder;
  final bool enabled;
  final int? highlightIndex;
  final String? emptyResultsText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemStyle = decoration.itemTextStyle;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: decoration.itemPadding,
          child: Text(
            emptyResultsText ?? 'No Data Found',
            textAlign: TextAlign.center,
            style: itemStyle?.copyWith(color: theme.hintColor),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = isSelected(item);
        final highlighted = highlightIndex != null && highlightIndex == index;

        final Color rowBg;
        if (highlighted) {
          rowBg = decoration.keyboardHighlightBackgroundColor ??
              theme.colorScheme.surfaceContainerHighest;
        } else if (selected) {
          rowBg = decoration.selectedItemBackgroundColor ??
              theme.colorScheme.primary.withValues(alpha: 0.10);
        } else {
          rowBg = decoration.fillColor ?? Colors.white;
        }

        final Widget tile = itemBuilder?.call(item) ??
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              minVerticalPadding: 0,
              contentPadding: decoration.itemPadding,
              title: Text(
                itemLabel(item),
                style: itemStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: indicatorTrailing && indicatorBuilder != null
                  ? indicatorBuilder!(context, selected)
                  : null,
              leading: !indicatorTrailing && indicatorBuilder != null
                  ? indicatorBuilder!(context, selected)
                  : null,
            );

        final paddedCustom = itemBuilder != null
            ? Padding(
                padding: decoration.itemPadding,
                child: tile,
              )
            : tile;

        return Material(
          color: rowBg,
          child: InkWell(
            onTap: enabled ? () => onSelect(item) : null,
            child: paddedCustom,
          ),
        );
      },
    );
  }
}
