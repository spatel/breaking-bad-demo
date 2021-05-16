@testable import BreakingBad
import XCTest
import Combine

final class QuoteListViewModelTests: XCTestCase {
  
  private var cancelBag = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    AppStore.fake.appEnvironment.keyValueStore.reset()
  }
  
  override func tearDown() {
    super.tearDown()
    cancelBag.forEach { $0.cancel() }
  }
  
  func testLoadSuccess() {
    // Given
    let appStore = AppStore.fake
    let viewModel = QuoteListViewModel(appStore: appStore, character: .walterWhite)
    
    // When
    let didLoadQuotes = expectation(description: "didLoadQuotes")
    
    viewModel
      .$quotes
      .dropFirst()
      .sink { updatedQuotes in
        didLoadQuotes.fulfill()
      }
      .store(in: &cancelBag)
    
    viewModel.onAppear.send()

    wait(for: [didLoadQuotes], timeout: 1.0)
    
    // Then
    XCTAssertEqual(11, viewModel.quotes.count)
    XCTAssertNil(viewModel.error)
  }
  
  func testLoadFailure() {
    // Given
    let appStore = AppStore(appEnvironment: .failingAPI)
    let viewModel = QuoteListViewModel(appStore: appStore, character: .walterWhite)
    
    // When
    let loadQuotesFailure = expectation(description: "loadQuotesFailure")
    
    viewModel
      .$error
      .dropFirst()
      .sink { updatedQuotes in
        loadQuotesFailure.fulfill()
      }
      .store(in: &cancelBag)
    
    viewModel.onAppear.send()

    wait(for: [loadQuotesFailure], timeout: 1.0)
    
    // Then
    XCTAssertEqual(0, viewModel.quotes.count)
    XCTAssertNotNil(viewModel.error)
  }
}
