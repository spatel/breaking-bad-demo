@testable import BreakingBad
import XCTest
import Combine

final class SubmitReviewViewModelTests: XCTestCase {
  
  private var cancelBag = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    AppStore.fake.appEnvironment.keyValueStore.reset()
  }
  
  override func tearDown() {
    super.tearDown()
    cancelBag.forEach { $0.cancel() }
  }
  
  func testSubmittingAReview() {
    // Given
    let appStore = AppStore.fake
    let viewModel = SubmitReviewViewModel(appStore: appStore)
    
    // When
    let submitReviewResponse = expectation(description: "submit review")
    viewModel.save.send()

    appStore
      .delegateActions
      .submitReviewResponse
      .sink { result in
        submitReviewResponse.fulfill()
      }
      .store(in: &cancelBag)
    
    wait(for: [submitReviewResponse], timeout: 1.0)
    
    // Then
    XCTAssertNotNil(viewModel.error) // We expect it to fail
  }

}
