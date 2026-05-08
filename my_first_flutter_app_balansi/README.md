# Pokédex Specs Browser

A minimalist, premium Flutter app for browsing the first **721 Pokémon** (Generations 1–6). Built with clean architecture, type-based theming, and offline-friendly caching.

![Flutter](https://img.shields.io/badge/Flutter-3.41-blue) ![Dart](https://img.shields.io/badge/Dart-3.11-blue) ![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

- **Browse 721 Pokémon** in a smooth two-column glassmorphism grid (Gen 1–6 only).
- **Real-time search** by name or Pokédex ID.
- **Detail screen** with hero artwork, type pills, height/weight/abilities, and animated base-stat bars.
- **Type-based theming** — every card and detail screen is tinted by the Pokémon's primary type using the canonical 18-type color palette.
- **Favorites** persisted across launches with a tap of the heart.
- **Offline-first** — first launch caches the full list locally; subsequent launches open instantly without a network call.
- **Premium typography** with Google Fonts (Inter for body, Poppins for headings).
- **Hero transitions**, fade-ins, and subtle micro-animations powered by `flutter_animate`.
- **Friendly error states** with retry buttons for network failures.

---

## 🧱 Tech Stack

| Concern              | Package                              |
| -------------------- | ------------------------------------ |
| State management     | `flutter_riverpod` ^2.5.1            |
| Networking           | `dio` ^5.7.0                         |
| Local persistence    | `hive` ^2.2.3 + `hive_flutter` ^1.1.0 |
| Typography           | `google_fonts` ^6.2.1                |
| Animations           | `flutter_animate` ^4.5.0             |
| Code generation      | `hive_generator` + `build_runner`    |
| Data source          | [PokéAPI](https://pokeapi.co)        |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── api/         # Dio client + PokéAPI service
│   ├── database/    # Hive setup + favorites box
│   ├── models/      # Pokémon data models (+ generated Hive adapter)
│   ├── theme/       # Type colors + app theme
│   └── utils/       # ID padding, string casing
├── features/
│   ├── pokedex/     # Home grid + search
│   ├── details/     # Detail screen + stat bars + type pills
│   └── favorites/   # Favorites screen + heart toggle
├── main.dart        # Bootstraps Hive + ProviderScope + MaterialApp
└── routes.dart      # Named-route table
```

---

## 🚀 Running the App

> **Prereq:** [Flutter SDK 3.41+](https://docs.flutter.dev/get-started/install) on your `PATH`.
> Verify with `flutter --version`.

### 1. Clone & install dependencies

```bash
git clone <repo-url>
cd pokedex_specs_browser
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The `build_runner` step generates the Hive adapter (`pokemon_summary.g.dart`).

### 2. Pick a target device

```bash
flutter devices
```

Then run with one of the device IDs from the output. Specific instructions per platform below.

---

### 🌐 Web (easiest — no extra setup)

Runs in any modern browser. **Recommended for a quick demo.**

```bash
flutter run -d chrome
```

Other browsers also work (`-d edge`, `-d web-server`).

---

### 🤖 Android

Requires **Android Studio** with the Android SDK + at least one emulator or a physical device with USB debugging.

```bash
# List available emulators
flutter emulators

# Launch one
flutter emulators --launch <emulator_id>

# Run on it (or on a connected physical device)
flutter run -d android
```

If you don't have an emulator, create one from **Android Studio → Device Manager → Create device**.

---

### 🍎 iOS (Mac only)

Requires **Xcode** (full app from the Mac App Store, not just Command Line Tools) + iOS Simulator or physical device.

```bash
# Open the iOS Simulator
open -a Simulator

# Run
flutter run -d ios
```

For a physical device you'll also need to set up signing in `ios/Runner.xcworkspace`.

---

### 💻 macOS desktop (Mac only)

Requires the full **Xcode** app.

```bash
# Verify Xcode is selected (not just CLT)
xcode-select -p
# Should print: /Applications/Xcode.app/Contents/Developer
# If not:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept

flutter run -d macos
```

> **Common error:** `unable to find utility "xcodebuild"` means you only have Command Line Tools installed. Install Xcode from the Mac App Store and run the `xcode-select` command above.

---

### 🪟 Windows desktop

Requires **Visual Studio 2022** with the **"Desktop development with C++"** workload.

```bash
flutter config --enable-windows-desktop   # one-time
flutter run -d windows
```

---

### 🐧 Linux desktop

Requires the [Flutter Linux desktop deps](https://docs.flutter.dev/get-started/install/linux#additional-requirements):

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
flutter config --enable-linux-desktop     # one-time
flutter run -d linux
```

---

## 🛠️ Development Commands

```bash
# Static analysis (should report 0 issues)
flutter analyze

# Re-run code generation if you edit @HiveType models
dart run build_runner build --delete-conflicting-outputs

# Hot reload while running: press `r`
# Hot restart: press `R`
# Quit: press `q`
```

---

## 📡 How Data Flows

1. **First launch:** `pokedexListProvider` calls `GET https://pokeapi.co/api/v2/pokemon?limit=721` and writes the full list to a Hive box.
2. **Subsequent launches:** the cached list is returned **immediately** from Hive; a silent background refresh updates the cache if it succeeds.
3. **Detail screen:** `pokemonDetailProvider.family<int>` lazily fetches full details for whichever Pokémon you tap.
4. **Favorites:** the heart toggle writes to a separate Hive box keyed by Pokémon ID, so favorites survive app restarts and reinstalls of the cached list.

---

## 🐛 Troubleshooting

| Symptom                                          | Fix                                                                 |
| ------------------------------------------------ | ------------------------------------------------------------------- |
| `xcrun: error: unable to find utility "xcodebuild"` | Install full Xcode + `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| Hive `TypeNotFoundError` on launch               | Re-run `dart run build_runner build --delete-conflicting-outputs`   |
| Empty grid / "No internet" error                 | Check connectivity — first launch needs to reach `pokeapi.co`       |
| Stale data after app updates                     | Pull-to-refresh on the home screen, or clear app storage            |

---

## 📜 License

MIT — credit [PokéAPI](https://pokeapi.co) for all Pokémon data and sprites. Pokémon and Pokémon character names are trademarks of Nintendo.
