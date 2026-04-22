/// Cache strategy for async dropdown query results.
enum ApexDropdownCachePolicy {
  /// Do not cache results.
  none,

  /// Cache results in memory for the lifetime of the current app session.
  memoryPerSession,

  /// Cache results in memory and expire them using a time-to-live (TTL).
  memoryWithTtl,
}

