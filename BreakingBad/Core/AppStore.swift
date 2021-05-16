import Combine

final class AppStore: ObservableObject {
  
  // MARK: - Inputs
  let refresh = PassthroughSubject<Void, Never>()
  let like = PassthroughSubject<(Bool, Character.ID), Never>()
  let submitReview = PassthroughSubject<SubmitReviewRequest, Never>()
  
  // MARK: - Outputs
  @Published private(set) var characters = [Character]()
  @Published private(set) var likedCharacters = Set<Character.ID>()
  
  // MARK: - Delegate actions
  let delegateActions = DelegateActions()
  
  struct DelegateActions {
    let fetchCharactersResponse = PassthroughSubject<Result<[Character], APIClient.APIError>, Never>()
    let didUpdateLikes = PassthroughSubject<Void, Never>()
    let submitReviewResponse = PassthroughSubject<Result<Review, APIClient.APIError>, Never>()
  }
  
  let appEnvironment: AppEnvironment
  private var cancelBag = Set<AnyCancellable>()
  
  init(appEnvironment: AppEnvironment) {
    self.appEnvironment = appEnvironment
    
    // "Refresh" signal -> fetch characters
    refresh
      .flatMap { _ in appEnvironment.api.fetchCharacters().asResult() }
      .receive(on: appEnvironment.mainQueue)
      .sink { [weak self] result in
        guard let self = self else { return }
        if case let .success(characters) = result {
          self.characters = characters
          self.likedCharacters = appEnvironment.keyValueStore.fetchLikes()
        }
        self.delegateActions.fetchCharactersResponse.send(result)
      }
      .store(in: &cancelBag)
    
    // "Like" signal -> update likes
    like
      .sink { [weak self] isLiked, characterId in
        guard let self = self else { return }
        self.appEnvironment.keyValueStore.setIsLiked(to: isLiked, for: characterId)
        self.likedCharacters = self.appEnvironment.keyValueStore.fetchLikes()
        self.delegateActions.didUpdateLikes.send()

      }
      .store(in: &cancelBag)
    
    // "Review" signal -> submit the review
    submitReview
      .flatMap { request -> AnyPublisher<Result<Review, APIClient.APIError>, Never> in
        return appEnvironment.api.submitReview(request).asResult()
      }
      .receive(on: appEnvironment.mainQueue)
      .sink { [weak self] result in
        guard let self = self else { return }
        self.delegateActions.submitReviewResponse.send(result)
      }
      .store(in: &cancelBag)
  }

}


// MARK: - Real instance
extension AppStore {
  static let real = AppStore(appEnvironment: .real)
}

#if DEBUG
// MARK: - Fake instance
extension AppStore {
  static let fake = AppStore(appEnvironment: .fake)
}
#endif
