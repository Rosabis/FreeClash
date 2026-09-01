# Project Context

FlClash is a multi-platform proxy client based on ClashMeta (mihomo), built with Flutter, using a Material You design with Surfboard-like UI. This fork ships only a Windows portable build; the Android/macOS/Linux sources are kept but no longer packaged. On Windows, configuration and data are stored in the `config` folder beside the executable (`lib/common/portable.dart`), not in AppData.

## Version Notes

- Release CI pins Flutter 3.44.4. Local SDK may diverge, so trust the CI
  version as the source of truth for release builds.
- Dart SDK constraint: `>=3.8.0 <4.0.0`.

## Build Dependencies

Windows:

- Visual Studio with the C++ desktop workload.
- Go and Rust toolchains (Core and Helper builds are orchestrated by the
  setup build tool).
