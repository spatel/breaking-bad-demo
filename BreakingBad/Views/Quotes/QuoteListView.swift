import SwiftUI

struct QuoteListView: View {
  
  @StateObject private var viewModel: QuoteListViewModel
  
  typealias ActionHandler = () -> Void
  var onDone: ActionHandler?
  
  init(
    appStore: AppStore,
    character: Character,
    onDone: ActionHandler? = nil
  ) {
    self._viewModel = StateObject(
      wrappedValue: .init(appStore: appStore,
                          character: character)
    )
    self.onDone = onDone
  }
  
  var body: some View {
    Group {
      switch(viewModel.loadState) {
      case .loading:
        LoadingView()
      case .loaded:
        quotesList
      }
    }
    .navigationBarItems(
      trailing: Button("Done", action: { onDone?() })
    )
    .navigationTitle("Quotes")
    .onAppear {
      viewModel.onAppear.send()
    }
  }
  
  private var quotesList: some View {
    List {
      if let error = viewModel.error {
        ErrorView(error: error.localizedDescription)
      } else {
        if viewModel.quotes.isEmpty {
          Text("No quotes found for \(viewModel.character.name)")
        } else {
          ForEach(viewModel.quotes) { quote in
            Text(quote.quote)
          }
        }
      }
    }
  }
}

// MARK: - Previews
struct QuoteListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      QuoteListView(
        appStore: .fake,
        character: .walterWhite
      )
    }
  }
}
