import Cocoa

class Dock {
  private static var options: CGWindowListOption {
    [.optionOnScreenOnly, .excludeDesktopElements]
  }

  static func windowCount(for name: String) -> Int {
    guard let info = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as [AnyObject]? else {
      return 0
    }

    return info.filter { entry in
      guard let appName = entry[kCGWindowOwnerName] as? String,
            let bounds = entry[kCGWindowBounds] as? NSDictionary,
            appName == name else {
        return false
      }
      return bounds.object(forKey: "X") != nil
    }.count
  }

  static var missionControlIsActive: Bool {
    guard let info = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as [AnyObject]? else {
      return false
    }

    return !info.filter { entry in
      guard let appName = entry[kCGWindowOwnerName as String] as? String,
            let layer = entry[kCGWindowLayer as String] as? Int,
            appName == "Dock" &&
            layer == CGWindowLevelKey.desktopIconWindow.rawValue else {
        return false
      }

      return true
    }.isEmpty
  }

  static func openMissionControl(then handler: (() -> Void)? = nil) {
    let path = "/System/Applications/Mission Control.app"
    NSWorkspace.shared.open(URL(fileURLWithPath: path))
    handler?()
  }
}
