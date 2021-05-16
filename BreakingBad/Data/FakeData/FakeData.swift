import Foundation

extension Character {
  
  static let fakeAll: [Character] = JSONLoader.loadJSON(from: "characters-response.json")
  
  static let walterWhite = fakeAll.first { $0.id == 1 }!
}


extension Quote {
  
  static let fakeAll: [Quote] = JSONLoader.loadJSON(from: "all-quotes-response.json")
  
  static let walterWhite: [Quote] = JSONLoader.loadJSON(from: "walter-whites-quotes-response")
}


extension NSError {
  
  static func fake(domain: String = "com.fake.error",
                   code: Int = -123,
                   message: String) -> NSError {
      NSError(domain: domain,
              code: code,
              userInfo: [NSLocalizedDescriptionKey: message])
  }
  
  static let betterCallSaul: NSError = .fake(message: "Something went wrong: better call Saul?")
}
