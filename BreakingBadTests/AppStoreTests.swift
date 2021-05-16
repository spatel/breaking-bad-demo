@testable import BreakingBad
import XCTest
import Combine

final class AppStoreTests: XCTestCase {
  
  private var cancelBag = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    AppStore.fake.appEnvironment.keyValueStore.reset()
  }
  
  override func tearDown() {
    super.tearDown()
    cancelBag.forEach { $0.cancel() }
  }
  
  func testRefreshCharactersSuccess() {
    
    // Given
    let appStore = AppStore.fake
    
    // When
    let refreshResponseOK = expectation(description: "refreshResponseOK")

    appStore
      .delegateActions
      .fetchCharactersResponse
      .sink { result in
        if case .success = result {
          refreshResponseOK.fulfill()
        }
      }
      .store(in: &cancelBag)
    
    appStore.refresh.send()
    
    wait(for: [refreshResponseOK], timeout: 1.0)
    
    // Then
    XCTAssertEqual(62, appStore.characters.count)
  }
  
  func testRefreshCharactersFailure() {
    // Given
    let appStore = AppStore(appEnvironment: .failingAPI)
    
    // When
    let refreshResponseFailure = expectation(description: "refreshResponseFailure")

    appStore
      .delegateActions
      .fetchCharactersResponse
      .sink { result in
        if case .failure = result {
          refreshResponseFailure.fulfill()
        }
      }
      .store(in: &cancelBag)
    
    appStore.refresh.send()
    
    wait(for: [refreshResponseFailure], timeout: 1.0)
    
    // Then
    XCTAssertEqual(0, appStore.characters.count)
  }
}
