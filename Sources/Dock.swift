import Cocoa

class Dock {
  private static var options: CGWindowListOption {
    [.optionOnScreenOnly, .excludeDesktopElements]
  }

  static func windowCount() -> Int {
    guard let info = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as [AnyObject]? else {
      return 0
    }

    return info.filter { entry in
      guard let bounds = entry[kCGWindowBounds] as? NSDictionary,
            let appName = entry[kCGWindowOwnerName] as? String,
            let isOnScreen = entry[kCGWindowIsOnscreen] as? Bool,
            let layer = entry[kCGWindowLayer] as? Int32,
            appName != "Dock" else {
        return false
      }

      guard bounds.object(forKey: "X") != nil else {
        return false
      }

      let validLayerRange = 0...CGWindowLevelKey.desktopIconWindow.rawValue

      guard validLayerRange.contains(layer) else { return false }

      return true
    }.count
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
