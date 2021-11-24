import Cocoa

final class TimerController {
  var timer: Timer? { willSet { timer?.invalidate() } }
  let session: Session

  internal init(session: Session) {
    self.session = session
  }

  func addTimer() {
    let timer = Timer(timeInterval: 0.5,
                      repeats: true,
                      block: handle(_:))
    self.timer = timer
    RunLoop.current.add(timer, forMode: .default)
  }

  private func handle(_ timer: Timer) {
    guard WindowManager.missionControlIsActive else { return }

    let windowCount = WindowManager.windowCount()
    if windowCount > session.windowCount {
      self.timer = nil
      MissionControl.realign {
        self.addTimer()
      }
    }
    session.windowCount = windowCount
  }
}
