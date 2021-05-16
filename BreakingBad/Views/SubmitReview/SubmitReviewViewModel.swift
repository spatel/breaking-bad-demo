import Combine
import Foundation

final class SubmitReviewViewModel: ObservableObject {

  // MARK: - Inputs
  let save = PassthroughSubject<Void, Never>()
  
  // MARK: - Outputs
  
  @Published var name = ""
  @Published var dateWatched = Date()
  @Published var detail = ""
  @Published var rating = 0
  @Published private(set) var error: APIClient.APIError?
  
  private var cancelBag = Set<AnyCancellable>()
  
  init(
    appStore: AppStore
  ) {

    // When the save button is tap, submit the (failing) API request
    save
      .sink { [weak self] _ in
        guard let self = self else { return }
        let request = SubmitReviewRequest(name: self.name,
                                          date: self.dateWatched,
                                          detail: self.detail,
                                          rating: self.rating)
        appStore.submitReview.send(request)
      }
      .store(in: &cancelBag)
    
    // Handle the API response
    appStore.delegateActions.submitReviewResponse
      .sink { [weak self] result in
        self?.updateUI(for: result)
      }
      .store(in: &cancelBag)
    }
  
  private func updateUI(for result: Result<Review, APIClient.APIError>) {
    
    switch result {
    case .success:
      // TODO - implement successful review response
      break
    case let .failure(error):
      self.error = error
    }
  }
  
}
