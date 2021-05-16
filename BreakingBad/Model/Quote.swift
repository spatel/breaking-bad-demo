import Foundation

struct Quote: Codable, Identifiable {
  
  enum CodingKeys: String, CodingKey {
    case id = "quote_id"
    case quote
    case author

  }
  
  let id: Int
  let quote: String
  let author: String
}
