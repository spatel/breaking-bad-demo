import SwiftUI

struct CharacterListView: View {
  
  @StateObject private var viewModel: CharacterListViewModel
  private let appStore: AppStore
  
  init(appStore: AppStore) {
    self.appStore = appStore
    self._viewModel = StateObject(wrappedValue: .init(appStore: appStore))
  }
  
  var body: some View {
    Group {
      switch(viewModel.loadState) {
      case .loading:
        LoadingView()
      case .loaded:
        characterList
      }
    }
    .onAppear(perform: viewModel.onAppear.send)
    .navigationTitle("Characters")
    .navigationBarItems(
      trailing: refreshButton(action: viewModel.refresh.send)
    )
  }
  
  private func refreshButton(action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Image(systemName: "arrow.clockwise")
    }
  }
  
  private var characterList: some View {
    List {
      if let error = viewModel.error {
        ErrorView(error: error.localizedDescription)
      }
      ForEach(viewModel.characterDetails) { characterDetail in
        NavigationLink(
          destination: CharacterDetailView(
            appStore: appStore,
            characterDetail: characterDetail
          )
        ) {
          row(with: characterDetail)
        }
      }
    }.listStyle(PlainListStyle())
  }
  
  private func row(with characterDetail: CharacterDetail) -> some View {
    HStack {
      Text(characterDetail.character.name)
      Spacer()
      Text(characterDetail.isLiked ? Image(systemName: "hand.thumbsup.fill") : Image(systemName: "hand.thumbsup"))
    }
  }
}

// MARK: - Previews
struct CharacterListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CharacterListView(appStore: .fake)
    }
  }
}
