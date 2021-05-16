@testable import BreakingBad
import XCTest
import Combine

final class CharacterDetailViewModelTests: XCTestCase {
  
  private var cancelBag = Set<AnyCancellable>()
  
  override func setUp() {
    super.setUp()
    AppStore.fake.appEnvironment.keyValueStore.reset()
  }
  
  override func tearDown() {
    super.tearDown()
    cancelBag.forEach { $0.cancel() }
  }
  
  func testLoadingACharacter() {
    
    // Given
    let appStore = AppStore.fake
    
    // When
    let viewModel = CharacterDetailViewModel(
      appStore: appStore,
      characterDetail: .init(character: .walterWhite, isLiked: false)
    )
    
    // Then
    XCTAssertEqual("Walter White", viewModel.detail.character.name)
    XCTAssertEqual("High School Chemistry Teacher\nMeth King Pin", viewModel.detail.character.occupationText)
    XCTAssertEqual("1, 2, 3, 4, 5", viewModel.detail.character.appearancesText)
    XCTAssertEqual("", viewModel.detail.character.betterCallSaulAppearancesText)
    XCTAssertFalse(viewModel.detail.isLiked)
  }
  
  func testLikingACharacter() {
    // Given
    let appStore = AppStore.fake
    
    // When
    let viewModel = CharacterDetailViewModel(
      appStore: appStore,
      characterDetail: .init(character: .walterWhite, isLiked: false)
    )
    
    let didSaveLike = expectation(description: "didSaveLike")

    appStore
      .delegateActions
      .didUpdateLikes
      .sink { result in
        didSaveLike.fulfill()
      }
      .store(in: &cancelBag)
    
    viewModel.detail.isLiked = true
    
    wait(for: [didSaveLike], timeout: 1.0)
    
    // Then
    XCTAssertEqual("Walter White", viewModel.detail.character.name)
    XCTAssertTrue(viewModel.detail.isLiked)

  }
}
