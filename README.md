# apex_dropdown

Single- and **multi-select** dropdown widgets for Flutter with a **controllerless** API, **safe handling of stale values**, **optional in-overlay search**, and **adaptive overlay placement** (opens upward when there is not enough room below). The package avoids common production issues such as crashes when the current selection is missing from `items` after a refresh, and ensures the overlay is torn down on dispose and route pop.

## Features

| Feature | Status |
|--------|--------|
| `ApexDropdown<T>` — single select, overlay list, keyboard navigation | Supported |
| Local search (`searchEnabled`, `searchMatcher`, `searchHintText`) | Supported |
| `compareFn` for model identity (e.g. match by `id`) | Supported |
| `ApexDropdownDecoration` — field and list styling, overlay geometry | Supported |
| `ApexDropdownFormField<T>` — `FormField` + validation | Supported |
| `ApexMultiDropdown<T>` — multi select, chips or count summary, `maxSelection` | Supported |
| `ApexMultiDropdownFormField<T>` — multi `FormField` + validation | Supported |
| Adaptive vertical placement + clamped panel height (keyboard / safe area) | Supported |
| `ApexAsyncDropdown<T>` (and form field) | Stub / planned |

## Installation

Add the dependency to `pubspec.yaml`:

```yaml
dependencies:
  apex_dropdown: ^1.0.0
```

```bash
flutter pub get
```

Import:

```dart
import 'package:apex_dropdown/apex_dropdown.dart';
```

## Quick start

```dart
class FruitPicker extends StatefulWidget {
  const FruitPicker({super.key});

  @override
  State<FruitPicker> createState() => _FruitPickerState();
}

class _FruitPickerState extends State<FruitPicker> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return ApexDropdown<String>(
      items: const ['Apple', 'Banana', 'Cherry'],
      itemLabel: (s) => s,
      value: selected,
      hintText: 'Select a fruit',
      onChanged: (v) => setState(() => selected = v),
    );
  }
}
```

## `ApexDropdown<T>`

Main constructor parameters:

| Parameter | Description |
|-----------|-------------|
| `items` | List of options. |
| `itemLabel` | String shown in the field and in each row (unless `itemBuilder` is used). |
| `onChanged` | Called with the new value (or `null` if you clear selection in a custom flow). |
| `value` | Currently selected item; can be a different instance than the one in `items` if `compareFn` matches. |
| `compareFn` | `(a, b) => true` when the same logical item; defaults to `==`. **Use for models** (e.g. `(a, b) => a.id == b.id`). |
| `hintText` | Placeholder when nothing is selected. |
| `enabled` | Disables interaction when `false`. |
| `decoration` | `ApexDropdownDecoration` for colors, typography, padding, overlay limits. |
| `itemBuilder` | Custom row widget; you are responsible for layout; list padding still applies around custom rows. |
| `searchEnabled` | Shows a search field at the top of the overlay. |
| `searchHintText` | Hint for the search field. |
| `searchMatcher` | `(item, query) => bool`; default matches case-insensitive substring on `itemLabel(item)`. |
| `emptyResultsText` | Message when search yields no rows. |
| `onOpenChanged` | `ValueChanged<bool>` when overlay opens or closes. |
| `onDismissed` | Called when the overlay closes after having been open. |
| `onInvalidValue` | Debug aid: invoked in debug when `value` is not found in `items` after normalization. |

### Model objects and `compareFn`

After an API refresh, `items` may contain new instances while `value` still holds an older instance. Provide `compareFn` so the correct row stays selected and the field label resolves.

```dart
class Car {
  Car({required this.id, required this.name});
  final int id;
  final String name;
}

Car? selected;

ApexDropdown<Car>(
  items: cars,
  value: selected,
  itemLabel: (c) => c.name,
  compareFn: (a, b) => a.id == b.id,
  hintText: 'Select a car',
  onChanged: (c) => setState(() => selected = c),
);
```

### Local search

Default matcher: case-insensitive substring on `itemLabel(item)`.

```dart
ApexDropdown<String>(
  items: countries,
  itemLabel: (c) => c,
  value: selectedCountry,
  hintText: 'Country',
  searchEnabled: true,
  searchHintText: 'Search countries…',
  onChanged: (v) => setState(() => selectedCountry = v),
);
```

Custom matcher:

```dart
ApexDropdown<Car>(
  items: cars,
  value: selectedCar,
  itemLabel: (c) => c.name,
  compareFn: (a, b) => a.id == b.id,
  searchEnabled: true,
  searchMatcher: (car, query) {
    final q = query.toLowerCase();
    return car.name.toLowerCase().contains(q) ||
        car.id.toString().contains(q);
  },
  onChanged: (v) => setState(() => selectedCar = v),
);
```

### Overlay placement

When the menu opens, the package measures space above and below the field (respecting `MediaQuery` padding and keyboard `viewInsets`). It prefers opening **below**; if the configured `overlayMaxHeight` does not fit, it opens **above**; if neither side fits fully, it picks the larger side and **reduces** the panel height so it stays on screen.

## `ApexDropdownDecoration`

Pass via `decoration:` on `ApexDropdown` or `ApexDropdownFormField`. Unset colors and text styles are filled from `ThemeData` in `resolved(ThemeData)` (used internally after merge).

**Field (closed)**

- `textStyle`, `hintStyle` — selected value and hint.
- `padding` — inner padding of the closed field (default horizontal 10, vertical 8).
- `fieldHeight` — optional fixed height; omit for intrinsic height from text + padding.
- `borderRadius`, `borderColor`, `focusedBorderColor`, `disabledBorderColor`, `fillColor`, `hoverColor`.

**Overlay list**

- `itemTextStyle` — text style for row labels (separate from the closed field `textStyle`).
- `itemPadding` — `ListTile` content padding for each row (default horizontal 10, vertical 2).
- `selectedItemBackgroundColor` — row matching `value` (default: primary at low opacity).
- `keyboardHighlightBackgroundColor` — row highlighted by arrow keys (default: `surfaceContainerHighest`).

**Overlay panel**

- `overlayMaxHeight` — max height of the whole panel (search + list), default `300`.
- `overlayElevation`, `overlayBorderRadius`, `overlayOffset` — position gap under/over the field; vertical sign is flipped when opening above.
- `matchFieldWidth` — when `true`, menu width follows the field width.

**Indicators**

- `singleIndicatorBuilder` / `multiIndicatorBuilder` — trailing (or leading) selection affordance; single-select defaults to radio-style icons.

**Copy / merge**

- `copyWith(...)` — build a modified decoration (for example `base.copyWith(textStyle: myStyle, itemTextStyle: myItemStyle)`).

Example:

```dart
ApexDropdown<String>(
  items: const ['Small', 'Medium', 'Large'],
  itemLabel: (s) => s,
  value: size,
  hintText: 'Size',
  decoration: ApexDropdownDecoration(
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    itemTextStyle: const TextStyle(fontSize: 14),
    itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    selectedItemBackgroundColor: Colors.teal.withValues(alpha: 0.12),
    overlayMaxHeight: 280,
  ),
  onChanged: (v) => setState(() => size = v),
);
```

## `ApexDropdownFormField<T>`

Wraps `ApexDropdown` in a `FormField<T>` so you can use `validator`, `onSaved`, and `autovalidateMode`. The inner dropdown updates `FormFieldState.didChange` when the user selects a value.

Extra parameters (merged into `decoration` when set):

- `fieldTextStyle` — overrides `ApexDropdownDecoration.textStyle` for the closed field.
- `itemTextStyle` — overrides `ApexDropdownDecoration.itemTextStyle` for list labels.

```dart
final _formKey = GlobalKey<FormState>();
String? role;

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: ApexDropdownFormField<String>(
      items: const ['Admin', 'Editor', 'Viewer'],
      itemLabel: (s) => s,
      value: role,
      hintText: 'Role',
      fieldTextStyle: Theme.of(context).textTheme.titleSmall,
      itemTextStyle: Theme.of(context).textTheme.bodyMedium,
      validator: (v) => v == null ? 'Choose a role' : null,
      onChanged: (v) => setState(() => role = v),
      onSaved: (v) => role = v,
    ),
  );
}
```

## `ApexMultiDropdown<T>`

Multi-select uses the same overlay stack, placement, and search as `ApexDropdown`, but rows use the **checkbox** affordance from `ApexDropdownDecoration.multiIndicatorBuilder`, taps **toggle** selection without closing the menu, and the field shows either a **count** (`"3 selected"`), **chips** (with delete to remove), or **both** via `ApexDropdownChipDisplay`.

| Parameter | Description |
|-----------|-------------|
| `items` | Options shown in the overlay. |
| `values` | Current selection (any order). |
| `onChanged` | Called with the updated list after toggle or chip delete. |
| `itemLabel` | Label for each value in chips and list rows. |
| `compareFn` | Same as single-select; use for model identity. |
| `maxSelection` | Optional cap; further adds invoke `onSelectionLimitReached` and do not change the list. |
| `onSelectionLimitReached` | Called when the user tries to exceed `maxSelection`. |
| `preserveStaleValues` | If `false`, values not in `items` are omitted from the field display (see `normalizeMulti`). If `true`, stale entries stay visible so the user can remove them via chips. |
| `chipDisplay` | `count`, `chips`, or `countAndChips`. |
| `searchEnabled` / `searchMatcher` / `searchHintText` / `emptyResultsText` | Same behavior as single-select. |
| `itemBuilder` | Optional custom row; list padding still wraps custom tiles. |
| `onInvalidValue` | Debug callback for each selected entry not found in `items`. |

### Multi values (multi-select) example

Keep your selected items in a `List<T>` and update it from `onChanged`. The widget calls `onChanged` with the **full updated list** after each toggle (and after chip delete when using chips).

```dart
List<String> tags = ['dart'];

ApexMultiDropdown<String>(
  items: const ['dart', 'flutter', 'ios', 'android'],
  values: tags,
  itemLabel: (s) => s,
  chipDisplay: ApexDropdownChipDisplay.chips,
  maxSelection: 3,
  searchEnabled: true,
  hintText: 'Pick tags',
  onChanged: (v) => setState(() => tags = v),
);
```

### Multi values with model objects (`compareFn`)

If your `items` are model objects (and may be refreshed from an API), provide `compareFn` so the dropdown can match logical items (e.g. by `id`) even when instances change.

```dart
class Skill {
  Skill({required this.id, required this.name});
  final String id;
  final String name;
}

List<Skill> selectedSkills = [];

ApexMultiDropdown<Skill>(
  items: skillsFromApi,
  values: selectedSkills,
  itemLabel: (s) => s.name,
  compareFn: (a, b) => a.id == b.id,
  chipDisplay: ApexDropdownChipDisplay.countAndChips,
  hintText: 'Select skills',
  onChanged: (v) => setState(() => selectedSkills = v),
);
```

## `ApexMultiDropdownFormField<T>`

Same pattern as `ApexDropdownFormField`: wraps `ApexMultiDropdown`, calls `FormFieldState.didChange` on selection changes, supports `validator` / `onSaved`, and optional `fieldTextStyle` / `itemTextStyle` merged into `decoration`. Also forwards `onOpenChanged`, `onDismissed`, and `onInvalidValue`.

## Default font size (16)

By default, all dropdowns (single + multi, field + list items) use **font size 16**. You can override per-widget via `decoration: ApexDropdownDecoration(textStyle: ..., itemTextStyle: ...)` (or on the form fields via `fieldTextStyle` / `itemTextStyle`).

## Safety and lifecycle

- **Stale selection (single)**: If `value` is not in `items`, the UI shows the hint instead of throwing. In debug mode, warnings are logged and `onInvalidValue` may be called.
- **Stale selection (multi)**: Entries in `values` that are not in `items` are logged in debug (`onInvalidValue` per stale item). With `preserveStaleValues: false`, the field hides stale entries from the summary until the parent trims `values`.
- **Overlay lifecycle**: The overlay entry is removed when the widget is disposed and when the enclosing route is popped (scoped will-pop callback).

## Planned (stub in repo)

`ApexAsyncDropdown` and `ApexAsyncDropdownFormField` are exported for API stability but currently show placeholder UI.

## Links

- **Repository**: `https://github.com/yourusername/apex_dropdown`
- **Issues**: `https://github.com/yourusername/apex_dropdown/issues`

Replace the repository URLs with your real GitHub paths when you publish.
