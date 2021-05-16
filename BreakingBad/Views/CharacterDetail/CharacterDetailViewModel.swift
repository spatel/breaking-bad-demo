import Combine
import Foundation

final class CharacterDetail: ObservableObject, Identifiable {
  var id: Int { character.id }
  let character: Character
  @Published var isLiked: Bool
  
  init(character: Character,
       isLiked: Bool) {
    self.character = character
    self.isLiked = isLiked
  }
}

final class CharacterDetailViewModel: ObservableObject {
  
  // MARK: - Inputs
  let onAppear = PassthroughSubject<Void, Never>()
  let onRefresh = PassthroughSubject<Void, Never>()
  let viewQuotes = PassthroughSubject<Void, Never>()

  // MARK: - Outputs
  @Published var detail: CharacterDetail
  
  private var cancelBag = Set<AnyCancellable>()
  
  init(
    appStore: AppStore,
    characterDetail: CharacterDetail
  ) {
    self.detail = characterDetail
    
    detail
      .$isLiked
      .dropFirst()
      .removeDuplicates()
      .sink { isLiked in
        appStore.like.send((isLiked, characterDetail.character.id))
      }
      .store(in: &cancelBag)
  }
}

// MARK: - Character UI extensions
extension Character {
  var occupationText: String {
    occupation.joined(separator: "\n")
  }
  
  var appearancesText: String {
    appearance
      .map(String.init)
      .joined(separator: ", ")
  }
  
  var betterCallSaulAppearancesText: String {
    betterCallSaulAppearance
      .map(String.init)
      .joined(separator: ", ")
  }
  
  var birthdayText: String {
    switch birthday {
    case .unknown:
      return "Unknown"
    case let .valid(date):
      return DateFormatter.birthdayUIDate.string(from: date)
    }
  }
}

extension DateFormatter {
  static let birthdayUIDate: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    return dateFormatter
  }()
}
