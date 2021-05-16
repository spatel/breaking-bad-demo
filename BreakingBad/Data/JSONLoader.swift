import Foundation

enum JSONLoader {
  
  private class ThisBundle {}
  
  static func loadJSON<D: Decodable>(from fileName: String,
                                     decoder: JSONDecoder = JSONDecoder()) -> D {
    Bundle(for: ThisBundle.self).decodedJSON(from: fileName, decoder: decoder)!
  }
}
