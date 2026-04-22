import 'package:flutter/material.dart';

import '../models/chip_display.dart';
import '../models/decoration.dart';

class ApexMultiDropdownField<T> extends StatelessWidget {
  const ApexMultiDropdownField({
    required this.link,
    required this.displayValues,
    required this.itemLabel,
    required this.chipDisplay,
    required this.hintText,
    required this.enabled,
    required this.isOpen,
    required this.onTap,
    required this.onRemove,
    required this.decoration,
    this.containerKey,
    super.key,
  });

  final LayerLink link;
  final List<T> displayValues;
  final String Function(T) itemLabel;
  final ApexDropdownChipDisplay chipDisplay;
  final String? hintText;
  final bool enabled;
  final bool isOpen;
  final VoidCallback onTap;
  final ValueChanged<T> onRemove;
  final ApexDropdownDecoration? decoration;
  final Key? containerKey;

  String _label(T item) {
    try {
      return itemLabel(item);
    } catch (_) {
      return item.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = (decoration ?? const ApexDropdownDecoration()).resolved(theme);
    final borderColor = !enabled
        ? d.disabledBorderColor
        : (isOpen ? d.focusedBorderColor : d.borderColor);

    final count = displayValues.length;
    final showHint = count == 0;
    final selectedText = showHint
        ? (hintText ?? '')
        : displayValues.map(_label).where((s) => s.isNotEmpty).join(', ');

    late final Widget body;
    if (d.fieldHeight != null) {
      // Keep the closed field the same height as single-select by default.
      // When constrained, render a single-line comma-separated summary.
      body = Text(
        selectedText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: showHint ? d.hintStyle : d.textStyle,
      );
    } else {
      switch (chipDisplay) {
        case ApexDropdownChipDisplay.count:
        body = Text(
          selectedText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: showHint ? d.hintStyle : d.textStyle,
        );
        break;
      case ApexDropdownChipDisplay.chips:
        if (count == 0) {
          body = Text(
            hintText ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: d.hintStyle,
          );
        } else {
          body = Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final v in displayValues)
                InputChip(
                  label: Text(
                    _label(v),
                    style: d.textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onDeleted: enabled ? () => onRemove(v) : null,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                ),
            ],
          );
        }
        break;
      case ApexDropdownChipDisplay.countAndChips:
        if (count == 0) {
          body = Text(
            hintText ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: d.hintStyle,
          );
        } else {
          final countStyle = d.textStyle?.copyWith(fontWeight: FontWeight.w600);
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$count selected', style: countStyle),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final v in displayValues)
                    InputChip(
                      label: Text(
                        _label(v),
                        style: d.textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: enabled ? () => onRemove(v) : null,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    ),
                ],
              ),
            ],
          );
        }
        break;
      }
    }

    final semanticsLabel = count == 0
        ? (hintText ?? 'Multi-select')
        : '$count items selected';

    final inner = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: body),
        const SizedBox(width: 6),
        AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: isOpen ? 0.5 : 0.0,
          child: Icon(
            Icons.expand_more,
            size: 20,
            color: enabled ? theme.iconTheme.color : theme.disabledColor,
          ),
        ),
      ],
    );

    final fieldChild = d.fieldHeight == null
        ? inner
        : ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: d.fieldHeight),
            child: Align(
              alignment: Alignment.centerLeft,
              child: inner,
            ),
          );

    return CompositedTransformTarget(
      link: link,
      child: Semantics(
        button: true,
        enabled: enabled,
        expanded: isOpen,
        label: semanticsLabel,
        child: FocusableActionDetector(
          enabled: enabled,
          autofocus: false,
          onShowHoverHighlight: (_) {},
          child: MouseRegion(
            cursor:
                enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? onTap : null,
              child: ConstrainedBox(
                constraints: d.fieldHeight == null
                    ? const BoxConstraints()
                    : BoxConstraints.tightFor(height: d.fieldHeight),
                child: AnimatedContainer(
                  key: containerKey,
                  duration: const Duration(milliseconds: 150),
                  padding: d.padding,
                  decoration: BoxDecoration(
                    color: d.fillColor,
                    borderRadius: d.borderRadius,
                    border: Border.all(color: borderColor ?? theme.dividerColor),
                  ),
                  child: fieldChild,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
