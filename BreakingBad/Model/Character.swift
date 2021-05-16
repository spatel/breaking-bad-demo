import Foundation

struct Character: Codable, Identifiable {
  
  enum CodingKeys: String, CodingKey {
    case id = "char_id"
    case appearance
    case betterCallSaulAppearance = "better_call_saul_appearance"
    case birthday
    case category
    case imageURL = "img"
    case name
    case nickname
    case occupation
    case portrayed
    case status
  }
  
  let id: Int
  let appearance: [Int]
  let betterCallSaulAppearance: [Int]
  let birthday: BirthdayDate
  let category: String
  let imageURL: URL?
  let name: String
  let nickname: String
  let occupation: [String]
  let portrayed: String
  let status: String
}


extension Sequence where Element == Character {
  func sortedByName() -> [Character] {
    self.sorted {
      $0.name.localizedStandardCompare($1.name) == .orderedAscending
    }
  }
}
