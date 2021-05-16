import SwiftUI

struct RootView: View {
  @StateObject var appStore: AppStore
  
  var body: some View {
    NavigationView {
      CharacterListView(appStore: appStore)
    }
  }
}

// MARK: - Previews
struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView(appStore: .fake)
  }
}
