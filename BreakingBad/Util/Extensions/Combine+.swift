import Combine

extension Publisher {
  
  public func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
    self.map(Result.success)
      .catch { Just(.failure($0)) }
      .eraseToAnyPublisher()
  }
}

