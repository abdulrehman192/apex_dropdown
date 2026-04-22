## 1.0.4 - 2026-04-22

- **UI**: Reduce the default closed-field height from 48 → 46 (applies to dropdown widgets and their `FormField` variants).
- **Docs**: Improve public API documentation coverage (adds missing DartDoc for `apex_dropdown` exports and `ApexAsyncDropdown` members).

## 1.0.0

Initial release of `apex_dropdown`.

- **ApexDropdown<T> (single select)**: controllerless dropdown with a route-safe overlay.
- **Model support**: `itemLabel` (required) + `compareFn` for identity matching (e.g. compare by ID).
- **Crash-proof mismatches**: never throws if `value` is not present in `items`; shows `hintText` instead and logs debug warnings (optionally calls `onInvalidValue` in debug).
- **Local search**: `searchEnabled` with default case-insensitive contains, plus `searchMatcher` for custom filtering.
- **Lifecycle safety**: overlay is removed on `dispose()` and dismissed on route pop (prevents setState-after-dispose / orphaned overlays).

Notes:
- `ApexAsyncDropdown<T>` is exported for API stability but currently renders placeholder UI while the full async implementation is in progress.
