import Foundation

enum BirthdayDate: Codable {
  case unknown
  case valid(Date)
  
  private static let apiDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  // JSON string value -> enum
  init(from decoder: Decoder) throws {
    let stringValue = try decoder.singleValueContainer().decode(String.self)
    if let date = Self.apiDateFormat.date(from: stringValue) {
      self = .valid(date)
    } else {
      self = .unknown
    }
  }
  
  // Enum -> JSON string value
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .unknown:
      try container.encode("Unknown")
    case let .valid(date):
      let stringValue = Self.apiDateFormat.string(from: date)
      try container.encode(stringValue)
    }
  }
}
