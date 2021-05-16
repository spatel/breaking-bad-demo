import Combine

final class CharacterListViewModel: ObservableObject {
  
  // MARK: - Inputs
  let onAppear = PassthroughSubject<Void, Never>()
  let refresh = PassthroughSubject<Void, Never>()
  

  // MARK: - Outputs
  enum LoadState {
    case loading
    case loaded
  }
      
  @Published private(set) var characters: [Character] = []
  @Published private(set) var likedCharacters = Set<Character.ID>()
  @Published private(set) var error: APIClient.APIError?
  @Published private(set) var loadState: LoadState = .loading
  
  var characterDetails: [CharacterDetail] {
    characters
      .map { .init(character: $0, isLiked: likedCharacters.contains($0.id)) }
  }
  
  private var cancelBag = Set<AnyCancellable>()
  
  init(appStore: AppStore) {
    
    // 1. Wait for the view to load (i.e. appear once)
    let onLoad = onAppear.first()
    
    refresh
      .map { _ in LoadState.loading }
      .assign(to: &self.$loadState)
    
    // 2. Whenever the screen loads or the refresh button is tapped, refresh the character data
    Publishers
      .Merge(onLoad, refresh)
      .sink {
        appStore.refresh.send()
      }
      .store(in: &cancelBag)
        
    // 3. Respond to data store changes
    appStore.delegateActions.fetchCharactersResponse
      .sink { [weak self] result in
        self?.updateUI(for: result, appStore: appStore)
      }
      .store(in: &cancelBag)
    
    appStore.delegateActions.didUpdateLikes
      .sink { [weak self] result in
        self?.likedCharacters = appStore.likedCharacters
      }
      .store(in: &cancelBag)
  }
  
  private func updateUI(for result: Result<[Character], APIClient.APIError>,
                        appStore: AppStore) {
    self.loadState = .loaded
    
    switch result {
    case let .success(characters):
      self.error = nil
      self.characters = characters
      self.likedCharacters = appStore.likedCharacters
    case let .failure(error):
      self.error = error
    }
  }
}

