import 'package:flutter/material.dart';

import '../models/decoration.dart';

class ApexDropdownField extends StatelessWidget {
  const ApexDropdownField({
    required this.link,
    required this.text,
    required this.hintText,
    required this.enabled,
    required this.isOpen,
    required this.onTap,
    required this.decoration,
    this.containerKey,
    super.key,
  });

  final LayerLink link;
  final String? text;
  final String? hintText;
  final bool enabled;
  final bool isOpen;
  final VoidCallback onTap;
  final ApexDropdownDecoration? decoration;
  final Key? containerKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = (decoration ?? const ApexDropdownDecoration()).resolved(theme);

    final borderColor = !enabled
        ? d.disabledBorderColor
        : (isOpen ? d.focusedBorderColor : d.borderColor);

    final display = text;
    final showHint = (display == null || display.isEmpty);

    return CompositedTransformTarget(
      link: link,
      child: Semantics(
        button: true,
        enabled: enabled,
        expanded: isOpen,
        label: showHint ? (hintText ?? 'Dropdown') : 'Dropdown, $display',
        child: FocusableActionDetector(
          enabled: enabled,
          autofocus: false,
          onShowHoverHighlight: (_) {},
          child: MouseRegion(
            cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          showHint ? (hintText ?? '') : display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: showHint ? d.hintStyle : d.textStyle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isOpen ? 0.5 : 0.0,
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: enabled
                              ? theme.iconTheme.color
                              : theme.disabledColor,
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
    );
  }
}

