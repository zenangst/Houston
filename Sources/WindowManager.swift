import Cocoa

final class WindowManager {
  private static var options: CGWindowListOption {
    [.optionOnScreenOnly, .excludeDesktopElements]
  }

  private static var windowInfo: [AnyObject] {
    CGWindowListCopyWindowInfo(options, kCGNullWindowID) as [AnyObject]? ?? []
  }

  private static let validLayerRange: ClosedRange<Int32> = 0...CGWindowLevelKey.desktopIconWindow.rawValue

  /// Check if Mission Control is active by checking the layer of the Dock application.
  /// The layer changes level when Mission Control is active.
  static var missionControlIsActive: Bool {
    !windowInfo.filter { entry in
      guard let appName = entry[kCGWindowOwnerName as String] as? String,
            let layer = entry[kCGWindowLayer as String] as? Int,
            appName == "Dock" &&
            layer == CGWindowLevelKey.desktopIconWindow.rawValue else {
        return false
      }

      return true
    }.isEmpty
  }

  /// Get the current window count for all applications that satisfy the valid layer range
  /// and have a bounds set.
  /// - Returns: The current amount of windows present.
  static func windowCount() -> Int {
    windowInfo.filter { entry in
      guard let bounds = entry[kCGWindowBounds] as? NSDictionary,
            let appName = entry[kCGWindowOwnerName] as? String,
            let layer = entry[kCGWindowLayer] as? Int32,
            appName != "Dock" else {
        return false
      }

      // Check that the windows has an X coordinate.
      guard bounds.object(forKey: "X") != nil else { return false }

      // Do not include layers that go beyond the regular window layer range,
      // such as windows appearing in the menu bar.
      guard validLayerRange.contains(layer) else { return false }

      return true
    }.count
  }

  /// Get the current window count for an application.
  /// It only includes windows that have a bounds set.
  /// - Parameter name: The localized name for the application
  /// - Returns: The amount of opens windows for an application
  static func windowCount(applicationNamed name: String) -> Int {
    windowInfo.filter { entry in
      guard let appName = entry[kCGWindowOwnerName] as? String,
            let bounds = entry[kCGWindowBounds] as? NSDictionary,
            appName == name else {
        return false
      }
      return bounds.object(forKey: "X") != nil
    }.count
  }
}
