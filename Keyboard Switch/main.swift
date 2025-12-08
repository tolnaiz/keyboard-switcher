import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Keep a strong reference to prevent deallocation
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
