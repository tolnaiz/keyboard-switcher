import Cocoa
import Carbon

// MARK: - Input Source Management

enum InputSourceError: Error, LocalizedError {
    case notFound(String)
    case selectionFailed(String)

    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Input source '\(id)' not found"
        case .selectionFailed(let id):
            return "Failed to select input source '\(id)'"
        }
    }
}

struct InputSourceManager {

    /// Select an input source by its ID
    static func select(_ inputSourceID: String) throws {
        let properties = [kTISPropertyInputSourceID as String: inputSourceID] as CFDictionary

        guard let sourceList = TISCreateInputSourceList(properties, true)?.takeRetainedValue() as? [TISInputSource],
              let inputSource = sourceList.first else {
            throw InputSourceError.notFound(inputSourceID)
        }

        let status = TISSelectInputSource(inputSource)
        if status != noErr {
            throw InputSourceError.selectionFailed(inputSourceID)
        }

        NSLog("Keyboard Switch: Selected input source: %@", inputSourceID)
    }

    /// Get the current keyboard input source ID
    static func currentInputSourceID() -> String? {
        guard let inputSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else {
            return nil
        }

        guard let idPtr = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID) else {
            return nil
        }

        return Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
    }

    /// List all enabled input sources (for debugging)
    static func listEnabledInputSources() -> [(id: String, name: String)] {
        guard let sourceList = TISCreateInputSourceList(nil, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }

        return sourceList.compactMap { source -> (String, String)? in
            guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID),
                  let namePtr = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) else {
                return nil
            }

            let id = Unmanaged<CFString>.fromOpaque(idPtr).takeUnretainedValue() as String
            let name = Unmanaged<CFString>.fromOpaque(namePtr).takeUnretainedValue() as String
            return (id, name)
        }
    }
}

// MARK: - Configuration

struct KeyboardSwitchConfig: Codable {
    /// Default keyboard layout when no specific mapping is found
    var defaultLayout: String

    /// Bundle ID -> Keyboard Layout ID mappings
    var appLayouts: [String: String]

    static let configDirectory = ("~/.config/keyboard-switch" as NSString).expandingTildeInPath
    static let configPath = (configDirectory as NSString).appendingPathComponent("config.json")

    static func load() -> KeyboardSwitchConfig {
        let fileURL = URL(fileURLWithPath: configPath)

        do {
            let data = try Data(contentsOf: fileURL)
            let config = try JSONDecoder().decode(KeyboardSwitchConfig.self, from: data)
            NSLog("Keyboard Switch: Loaded config from %@", configPath)
            return config
        } catch {
            NSLog("Keyboard Switch: Could not load config (%@), creating default", error.localizedDescription)
            let defaultConfig = KeyboardSwitchConfig.createDefault()
            defaultConfig.save()
            return defaultConfig
        }
    }

    static func createDefault() -> KeyboardSwitchConfig {
        // Default config with common developer apps using US-QWERTZ
        let usQwertzLayout = "org.unknown.keylayout.USqwertz"

        return KeyboardSwitchConfig(
            defaultLayout: "com.apple.keyboardlayout.roman.keylayout.HungarianPro",
            appLayouts: [
                "com.sublimetext.4": usQwertzLayout,
                "com.jetbrains.PhpStorm": usQwertzLayout,
                "com.apple.Terminal": usQwertzLayout,
                "com.apple.dt.Xcode": usQwertzLayout,
                "com.googlecode.iterm2": usQwertzLayout,
                "com.torusknot.SourceTreeNotMAS": usQwertzLayout,
                "com.microsoft.VSCode": usQwertzLayout,
                "net.kovidgoyal.kitty": usQwertzLayout,
                "com.vscodium": usQwertzLayout,
                "com.todesktop.230313mzl4w4u92": usQwertzLayout
            ]
        )
    }

    func save() {
        let dirURL = URL(fileURLWithPath: KeyboardSwitchConfig.configDirectory)
        let fileURL = URL(fileURLWithPath: KeyboardSwitchConfig.configPath)

        do {
            // Create directory if it doesn't exist
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)

            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(self)
            try data.write(to: fileURL)
            NSLog("Keyboard Switch: Saved config to %@", KeyboardSwitchConfig.configPath)
        } catch {
            NSLog("Keyboard Switch: Failed to save config: %@", error.localizedDescription)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var config: KeyboardSwitchConfig!
    private var activationObserver: Any?

    override init() {
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("Keyboard Switch: applicationDidFinishLaunching")

        // Load configuration
        config = KeyboardSwitchConfig.load()
        NSLog("Keyboard Switch: Loaded %d app mappings", config.appLayouts.count)

        // Observe frontmost app changes.
        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            print("App activation notification received")
            let app = NSWorkspace.shared.frontmostApplication
            self.handleActivation(of: app)
        }

        // Apply once at launch for the current frontmost app.
        handleActivation(of: NSWorkspace.shared.frontmostApplication)
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let observer = activationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }

    private func handleActivation(of app: NSRunningApplication?) {
        guard let bundleID = app?.bundleIdentifier else { return }

        NSLog("Frontmost app bundle ID: %@", bundleID)

        // Look up the keyboard layout for this app, or use the default
        let inputSourceID = config.appLayouts[bundleID] ?? config.defaultLayout

        // Only switch if different from current
        if let currentID = InputSourceManager.currentInputSourceID(), currentID == inputSourceID {
            NSLog("Keyboard Switch: Already using %@, skipping", inputSourceID)
            return
        }

        NSLog("Switching to keyboard layout: %@", inputSourceID)

        do {
            try InputSourceManager.select(inputSourceID)
        } catch {
            NSLog("Keyboard Switch: %@", error.localizedDescription)
        }
    }
}
