# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedDoppler<T>(...)` — wraps a otel_doppler call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutDopplerInstrumentation()` / `Async()`.
