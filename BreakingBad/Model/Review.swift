import Foundation

struct Review: Codable, Identifiable {
  
  let id: Int
  let name: String
  let date: Date
  let rating: Int
}
