import Combine
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  private var runningApplicationWindows = 0
  private var subscriptions = [AnyCancellable]()
  private var runningApplicationSubscription: AnyCancellable?
  private var counter: Int = 0
  private var timer: Timer?

  func applicationDidFinishLaunching(_ notification: Notification) {
    NSWorkspace.shared
      .publisher(for: \.frontmostApplication)
      .compactMap { $0 }
      .sink { [weak self] runningApplication in
        guard let self = self, Dock.missionControlIsActive else { return }
        let applicationName: String = runningApplication.localizedName ?? ""
        self.runningApplicationWindows = Dock.windowCount(for: applicationName)
        self.counter = 10

        if self.runningApplicationWindows > 0 {
          Dock.openMissionControl {
            runningApplication.activate(options: .activateIgnoringOtherApps)
          }
        } else {
          if !runningApplication.isFinishedLaunching {
            self.runningApplicationSubscription = runningApplication
              .publisher(for: \.isFinishedLaunching)
              .sink { value in
                self.poll(applicationName)
                self.runningApplicationSubscription = nil
              }
          } else {
            self.poll(applicationName)
          }
        }
      }.store(in: &subscriptions)
  }

  func poll(_ applicationName: String) {
    let timer = Timer(timeInterval: 0.375, repeats: true) { timer in
      defer {
        self.counter -= 1
        if self.counter <= 0 {
          timer.invalidate()
        }
      }
      let openWindows = Dock.windowCount(for: applicationName)
      if self.runningApplicationWindows != openWindows {
        Dock.openMissionControl {
          let deadline = DispatchTime.now() + NSAnimationContext.current.duration + 0.035
          DispatchQueue.main.asyncAfter(deadline: deadline) { Dock.openMissionControl() }
        }
        self.runningApplicationWindows = openWindows
        timer.invalidate()
        self.counter = 0
      }
    }
    RunLoop.main.add(timer, forMode: .default)
    self.timer = timer
  }
}
