import SwiftUI

@main
struct BreakingBadApp: App {
  var body: some Scene {
    WindowGroup {
      RootView(appStore: .real)
    }
  }
}
