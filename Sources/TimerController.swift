import Cocoa

final class TimerController {
  var timer: Timer? { willSet { timer?.invalidate() } }
  let session: Session

  internal init(session: Session) {
    self.session = session
  }

  func addGlobalTimer() {
    let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      if WindowManager.missionControlIsActive {
        self.session.windowCount = WindowManager.windowCount()
        self.addMissionControlTimer()
      }
    }
    self.timer = timer
    RunLoop.current.add(timer, forMode: .default)
  }

  func addMissionControlTimer() {
    let timer = Timer(timeInterval: 0.5,
                      repeats: true,
                      block: handle(_:))
    self.timer = timer
    RunLoop.current.add(timer, forMode: .default)
  }

  private func handle(_ timer: Timer) {
    guard WindowManager.missionControlIsActive else {
      addGlobalTimer()
      return
    }

    let windowCount = WindowManager.windowCount()
    if windowCount > session.windowCount {
      self.timer = nil
      MissionControl.realign {
        self.addMissionControlTimer()
      }
    }
    session.windowCount = windowCount
  }
}

