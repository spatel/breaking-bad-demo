@testable import BreakingBad
import XCTest
import Combine

final class CharacterListViewModelTests: XCTestCase {
  
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
    let viewModel = CharacterListViewModel(appStore: appStore)
    
    // When
    let refreshResponse = expectation(description: "refreshCharacterListSucces")

    appStore
      .delegateActions
      .fetchCharactersResponse
      .sink { result in
        refreshResponse.fulfill()
      }
      .store(in: &cancelBag)
    
    viewModel.onAppear.send()
    
    wait(for: [refreshResponse], timeout: 1.0)
    
    // Then
    XCTAssertEqual(62, viewModel.characters.count)
    XCTAssertNil(viewModel.error)
    XCTAssertEqual(.loaded, viewModel.loadState)
    XCTAssertEqual(0, viewModel.likedCharacters.count)
  }
  
  func testLoadFailure() {
    // Given
    let appStore = AppStore(appEnvironment: .failingAPI)
    let viewModel = CharacterListViewModel(appStore: appStore)
    
    
    let refreshResponse = expectation(description: "refreshCharacterListFailure")

    appStore
      .delegateActions
      .fetchCharactersResponse
      .sink { result in
        refreshResponse.fulfill()
      }
      .store(in: &cancelBag)
    
    viewModel.onAppear.send()
    
    wait(for: [refreshResponse], timeout: 1.0)
    
    // Then
    XCTAssertEqual(0, viewModel.characters.count)
    XCTAssertNotNil(viewModel.error)
    XCTAssertEqual(.loaded, viewModel.loadState)
    XCTAssertEqual(0, viewModel.likedCharacters.count)
  }  
}
