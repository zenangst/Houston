import Cocoa
import Combine
import Foundation

final class FrontmostApplicationController {
  var subscription: AnyCancellable?
  let session: Session

  init(session: Session) {
    self.session = session
  }

  func subscribe(to publisher: NSObject.KeyValueObservingPublisher<NSWorkspace, NSRunningApplication?>) {
    self.subscription = publisher
      .compactMap { $0 }
      .sink { [weak self] runningApplication in
        guard let self = self, WindowManager.missionControlIsActive else { return }
        let applicationName: String = runningApplication.localizedName ?? ""

        if WindowManager.windowCount(applicationNamed: applicationName) > 0 {
          MissionControl.open {
            runningApplication.activate(options: .activateIgnoringOtherApps)
          }
        }
        self.session.windowCount = WindowManager.windowCount()
      }
  }
}
