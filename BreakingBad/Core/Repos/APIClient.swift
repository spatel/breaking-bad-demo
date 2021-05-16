import Foundation
import Combine

// N.B. Could have introduced a BreakBadAPI protocol (but a struct works equally fine and is just as testable)

// MARK: - APIClient
struct APIClient {
  
  var fetchCharacters: () -> AnyPublisher<[Character], APIError>
  var fetchQuotes: (FetchQuotesRequest) -> AnyPublisher<[Quote], APIError>
  var submitReview: (SubmitReviewRequest) -> AnyPublisher<Review, APIError>
}

struct FetchQuotesRequest {
  let character: Character
}

struct SubmitReviewRequest {
  let name: String
  let date: Date
  let detail: String
  let rating: Int
}


// MARK: - Real instance
extension APIClient {
  
  private struct RequestURL {
    let route: String
    
    var url: URL {
      let urlString = "https://breakingbadapi.com/api\(route)".replacingOccurrences(of: "//", with: "/")
      let components = URLComponents(string: urlString)!
      return components.url!
    }
  }
  
  private static let jsonDecoder = JSONDecoder()
  
  static let real = APIClient(
    
    fetchCharacters: {
      let url = RequestURL(route: "/characters").url
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map { data, _ in data }
        .decode(type: [Character].self, decoder: jsonDecoder)
        .mapError(APIClient.APIError.init)
        .eraseToAnyPublisher()
    },
    
    fetchQuotes: { params in
      
      let authorParams = params.character.name.replacingOccurrences(of: " ", with: "+")
      let url = RequestURL(route: "/quotes?author=\(authorParams)").url
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map { data, _ in data }
        .decode(type: [Quote].self, decoder: jsonDecoder)
        .mapError(APIClient.APIError.init)
        .eraseToAnyPublisher()
    },
    
    submitReview: { params in
      
      let url = RequestURL(route: "/bad-request-test").url
      
      return URLSession.shared.dataTaskPublisher(for: url)
        .map { data, _ in data }
        .decode(type: Review.self, decoder: jsonDecoder)
        .mapError(APIClient.APIError.init)
        .eraseToAnyPublisher()
    }
  )
}

extension APIClient {
  // MARK: - ApiError
  struct APIError: Error, Equatable {
    private let error: NSError
    
    init(error: Error) {
      self.error = error as NSError
    }
    
    var localizedDescription: String {
      error.localizedDescription
    }
  }
}

// MARK: - Fake instance(s)
extension APIClient {
  
  // Fake SUCCESS api
  static let fake = APIClient(
    
    fetchCharacters: {
      return Just(Character.fakeAll)
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    },
    
    fetchQuotes: { params in
      let filteredQuotes = Quote.fakeAll.filter {
        $0.author.lowercased() == params.character.name.lowercased()
      }
      return Just(filteredQuotes)
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
    },
    
    submitReview: { params in
      Fail(error: APIClient.APIError(error: NSError.betterCallSaul))
        .eraseToAnyPublisher()
    }
  )
  
  // Fake FAILURE api
  static let fakeFailingAPI = APIClient(
    
    fetchCharacters: {
      Fail(error: APIClient.APIError(error: NSError.betterCallSaul))
        .eraseToAnyPublisher()
    },
    
    fetchQuotes: { params in
      Fail(error: APIClient.APIError(error: NSError.betterCallSaul))
        .eraseToAnyPublisher()
    },
    
    submitReview: { params in
      Fail(error: APIClient.APIError(error: NSError.betterCallSaul))
        .eraseToAnyPublisher()
    }
  )
}
