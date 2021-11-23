import Combine
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  private var counter: Int = 0
  private var globalWindowCount = Dock.windowCount()
  private var runningApplicationSubscription: AnyCancellable?
  private var runningApplicationWindows = 0
  private var subscriptions = [AnyCancellable]()
  private var globalTimer: Timer? {
    willSet { globalTimer?.invalidate() }
  }
  private var frontmostApplicationTimer: Timer? {
    willSet { frontmostApplicationTimer?.invalidate() }
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.setActivationPolicy(.accessory)
    NSWorkspace.shared
      .publisher(for: \.frontmostApplication)
      .compactMap { $0 }
      .sink { runningApplication in
        guard Dock.missionControlIsActive else { return }
        let applicationName: String = runningApplication.localizedName ?? ""

        if Dock.windowCount(for: applicationName) > 0 {
          Dock.openMissionControl {
            runningApplication.activate(options: .activateIgnoringOtherApps)
          }
        }
      }.store(in: &subscriptions)

    addGlobalTimer()
  }

  private func addGlobalTimer() {
    let globalTimer = Timer(timeInterval: 0.5,
                            repeats: true,
                            block: runGlobalTimer(_:))
    self.globalTimer = globalTimer
    RunLoop.current.add(globalTimer, forMode: .default)
  }

  private func runGlobalTimer(_ timer: Timer) {
    guard Dock.missionControlIsActive else { return }

    let newWindowCount = Dock.windowCount()
    if newWindowCount > globalWindowCount {
      realignMissionControl()
      globalWindowCount = newWindowCount
    } else if newWindowCount != globalWindowCount {
      globalWindowCount = newWindowCount
    }
  }

  private func realignMissionControl() {
    Dock.openMissionControl {
      let deadline = DispatchTime.now() + NSAnimationContext.current.duration + 0.035
      DispatchQueue.main.asyncAfter(deadline: deadline) { Dock.openMissionControl() }
    }
  }
}
