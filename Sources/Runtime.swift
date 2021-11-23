import Cocoa

@main
final class Runtime: NSObject {
  static let application = NSApplication.shared
  static let delegate = AppDelegate()
  static func main() {
      application.delegate = delegate
      _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
  }
}
