# Agents

## Cursor Cloud specific instructions

### Project Overview

This is a Flutter-based Chain Reaction strategy board game targeting iOS, Android, and Web. See `README.md` for full project structure and commands.

### Environment

- Flutter SDK is installed at `/opt/flutter` and added to PATH via `~/.bashrc`.
- Standard commands: `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build web --release --no-web-resources-cdn`.

### Key Caveats

- **Web builds must use `--no-web-resources-cdn`** flag to bundle CanvasKit locally. The cloud VM has restricted outbound network access, so fetching CanvasKit from `www.gstatic.com` CDN will fail with `ERR_CONNECTION_RESET`.
- **`flutter run -d web-server`** (debug mode) requires a WebSocket debug connection that browsers in this environment cannot establish. Use a production build served via `python3 -m http.server` instead for manual testing.
- To serve the web build for manual testing: `cd build/web && python3 -m http.server 8080 --bind 0.0.0.0`.
- iOS and Android builds require native SDKs (Xcode / Android Studio) which are not available in the cloud VM. Web is the testable target here.
