import Combine
import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
  private lazy var session = Session()
  private lazy var timerController = TimerController(session: session)
  private lazy var frontmostController = FrontmostApplicationController(session: session)

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)
    timerController.addGlobalTimer()
    frontmostController.subscribe(to: NSWorkspace.shared.publisher(for: \.frontmostApplication))
  }
}
