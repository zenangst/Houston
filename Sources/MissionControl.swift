import Cocoa

enum MissionControl {
  /// Open the Mission Control application
  /// - Parameter handler: A completion closure that is called
  ///                      directly after the open application invocation
  ///                      occurred.
  static func open(then handler: (() -> Void)? = nil) {
    let path = "/System/Applications/Mission Control.app"
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
    handler?()
  }

  static func realign() {
    MissionControl.open {
      // TODO: Should this be a preference that you can toggle on and off?
      let deadline = DispatchTime.now() + NSAnimationContext.current.duration + 0.035
      DispatchQueue.main.asyncAfter(deadline: deadline) { MissionControl.open() }
    }
  }
}
