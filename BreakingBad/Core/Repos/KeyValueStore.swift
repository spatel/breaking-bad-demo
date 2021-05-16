import Foundation

struct KeyValueStore {
  typealias Key = String
  typealias Value = Any
  struct KeyValuePair {
    let key: Key
    let value: Value?
  }
  let get: (Key) -> Value?
  let set: (KeyValuePair) -> Void
}

// MARK: - Real instance
extension KeyValueStore {
  
  private static let standardDefaults = UserDefaults.standard
  static let real = KeyValueStore(
    get: { key -> Any? in
      standardDefaults.object(forKey: key)
    },
    set: { pair in
      standardDefaults.set(pair.value, forKey: pair.key)
    }
  )
}

// MARK: - "Likes" storage
extension KeyValueStore {
  
  private static let likedIdsKey: String = "likes"
  
  func fetchLikes() -> Set<Character.ID> {
    let likes = self.get(Self.likedIdsKey) as? [Character.ID] ?? []
    return Set(likes)
  }
  
  func setIsLiked(to isLiked: Bool, for characterId: Character.ID) {
    var updatedLikes = fetchLikes()
    
    if isLiked {
      updatedLikes.insert(characterId)
    } else {
      updatedLikes.remove(characterId)
    }
    
    self.set(.init(key: Self.likedIdsKey, value: Array(updatedLikes)))
  }
  
  func reset() {
    self.set(.init(key: Self.likedIdsKey, value: []))
  }
}

// MARK: - Fake instance
#if DEBUG
extension KeyValueStore {
  
  private static var inMemoryStorage =  [String: Any]()
  static let fake = KeyValueStore(
    get: { key -> Any? in
      inMemoryStorage[key]
    },
    set: { pair in
      inMemoryStorage[pair.key] = pair.value
    }
  )
}
#endif
