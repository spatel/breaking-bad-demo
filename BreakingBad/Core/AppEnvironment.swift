import Foundation

struct AppEnvironment {
  let api: APIClient
  let mainQueue: DispatchQueue
  let keyValueStore: KeyValueStore
}

extension AppEnvironment {
  
  static let real = AppEnvironment(
    api: .real,
    mainQueue: .main,
    keyValueStore: .real
  )
  
  static let fake = AppEnvironment(
    api: .fake,
    mainQueue: .main,
    keyValueStore: .fake
  )
  
  static let failingAPI = AppEnvironment(
    api: .fakeFailingAPI,
    mainQueue: .main,
    keyValueStore: .fake
  )
}
