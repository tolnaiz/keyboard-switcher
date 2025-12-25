# Keyboard Switch

A lightweight macOS menu bar utility that automatically switches keyboard input sources based on the active application. Perfect for developers who prefer a programmer-friendly layout (like US-QWERTZ) in code editors and terminals, but their native language layout elsewhere.

## Features

- 🔄 Automatic keyboard layout switching when apps gain focus
- ⚙️ JSON-based configuration with hot-reload (no restart needed)
- 🪶 Runs silently in the menu bar (no dock icon)
- 🖥️ Native macOS app using Carbon Text Input Source APIs

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 13+ (for building)

## Building

1. Clone the repository:
   ```bash
   git clone https://github.com/tolnaiz/keyboard-switch.git
   cd keyboard-switch
   ```

2. Open in Xcode:
   ```bash
   open "Keyboard Switch.xcodeproj"
   ```

3. Build and run with `⌘R`, or archive for release with `Product → Archive`.

Alternatively, build from the command line:
```bash
xcodebuild -project "Keyboard Switch.xcodeproj" -scheme "Keyboard Switch" -configuration Release
```

## Configuration

On first launch, the app creates a config file at:
```
~/.config/keyboard-switch/config.json
```

Example configuration:
```json
{
  "defaultLayout": "com.apple.keylayout.US",
  "appLayouts": {
    "com.apple.dt.Xcode": "org.unknown.keylayout.USqwertz",
    "com.microsoft.VSCode": "org.unknown.keylayout.USqwertz",
    "com.apple.Terminal": "org.unknown.keylayout.USqwertz"
  }
}
```

- **defaultLayout**: Keyboard layout used for apps not in `appLayouts`
- **appLayouts**: Map of app bundle IDs → keyboard layout IDs

Changes are applied immediately—no restart required.

### Finding Bundle IDs and Layout IDs

To find an app's bundle ID:
```bash
osascript -e 'id of app "App Name"'
```

To list available keyboard layouts, check `System Preferences → Keyboard → Input Sources` or use the Console.app to view logs when switching apps.

## License

MIT
