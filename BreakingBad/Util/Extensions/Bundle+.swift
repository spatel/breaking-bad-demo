import Foundation

extension Bundle {
  
  public func decodedJSON<D: Decodable>(from filename: String,
                                        decoder: JSONDecoder = JSONDecoder()) -> D? {
    let includesFileExtension = (filename as NSString).pathExtension.lowercased() == "json"
    let resource = includesFileExtension ? (filename as NSString).deletingPathExtension : filename
    
    guard let url = url(forResource: resource, withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let decodedValue = try? decoder.decode(D.self, from: data) else {
      return nil
    }
    
    return decodedValue
  }
  
}
