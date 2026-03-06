# Chain Reaction Game

A multiplayer strategy board game built with Flutter for iOS, Android, and Web.

## Game Rules

- Players take turns placing orbs on a grid
- Each cell has a **critical mass** based on position: corners = 2, edges = 3, center = 4
- When a cell reaches critical mass, it **explodes** sending orbs to neighboring cells
- Explosions can trigger **chain reactions** in adjacent cells
- Captured cells change to the exploding player's color
- A player is eliminated when they have no orbs remaining
- Last player standing wins!

## Development Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.41+)
- For iOS: Xcode (macOS only)
- For Android: Android Studio with Android SDK

### Install Dependencies

```bash
flutter pub get
```

### Run (Web)

```bash
flutter run -d chrome
```

For headless/server environments (e.g., CI), build and serve:

```bash
flutter build web --release --no-web-resources-cdn
cd build/web && python3 -m http.server 8080
```

### Run (iOS/Android)

```bash
flutter run  # auto-detects connected device or emulator
```

### Lint

```bash
flutter analyze
```

### Test

```bash
flutter test
```

### Build

```bash
flutter build web --release --no-web-resources-cdn
flutter build apk --release    # Android
flutter build ios --release     # iOS (macOS only)
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── cell.dart          # Grid cell model
│   ├── player.dart        # Player model with colors
│   └── game_state.dart    # Game logic and state management
├── screens/
│   ├── home_screen.dart   # Main menu with settings
│   └── game_screen.dart   # Game board and HUD
└── widgets/
    ├── game_board.dart    # Grid layout widget
    ├── cell_widget.dart   # Individual cell with animations
    └── orb_painter.dart   # Custom painter for orb rendering
```
