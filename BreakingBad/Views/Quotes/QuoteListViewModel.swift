import Combine

final class QuoteListViewModel: ObservableObject {
  
  // MARK: - Inputs
  let onAppear = PassthroughSubject<Void, Never>()
  let onRefresh = PassthroughSubject<Void, Never>()
  
  // MARK: - Outputs
  enum LoadState {
    case loading
    case loaded
  }
  
  let character: Character
  @Published private(set) var quotes: [Quote] = []
  @Published private(set) var error: APIClient.APIError?
  @Published private(set) var loadState: LoadState = .loading
  
  private var cancelBag = Set<AnyCancellable>()
  
  init(
    appStore: AppStore,
    character: Character
  ) {
    let appEnvironment = appStore.appEnvironment
    self.character = character
    
    // 1. Wait for the "load" signal
    let onLoad = onAppear.first()
    
    // 2. Trigger API request when the view loads
    onLoad
      .flatMap { _ -> AnyPublisher<Result<[Quote], APIClient.APIError>, Never> in
        let request = FetchQuotesRequest(character: character)
        return appEnvironment.api.fetchQuotes(request).asResult()
      }
      .receive(on: appEnvironment.mainQueue)
      .sink { [weak self] result in
        self?.updateUI(for: result)
      }
      .store(in: &cancelBag)
  }
  
  private func updateUI(for result: Result<[Quote], APIClient.APIError>) {
    self.loadState = .loaded
    
    switch result {
    case let .success(quotes):
      self.error = nil
      self.quotes = quotes.sorted {
        $0.quote.localizedStandardCompare($1.quote) == .orderedAscending
      }
    case let .failure(error):
      self.error = error
    }
  }
}
