import SwiftUI
import Combine
import Foundation

//
// Adapted from here: https://github.com/V8tr/AsyncImage
// 
//
class ImageLoader: ObservableObject {
  @Published var image: UIImage?
  
  private(set) var isLoading = false
  
  private let url: URL
  private var cancellable: AnyCancellable?
  
  private static let backgroundQueue = DispatchQueue(label: "image-queue")
  
  init(url: URL) {
    self.url = url
  }
  
  func load() {
    guard !isLoading else { return }
    
    cancellable = URLSession.shared.dataTaskPublisher(for: url)
      .map { UIImage(data: $0.data) }
      .replaceError(with: nil)
      .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                    receiveOutput: { _ in  },
                    receiveCompletion: { [weak self] _ in self?.onFinish() },
                    receiveCancel: { [weak self] in self?.onFinish() })
      .subscribe(on: Self.backgroundQueue)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in self?.image = $0 }
  }
  
  func cancel() {
    cancellable?.cancel()
  }
  
  private func onStart() {
    isLoading = true
  }
  
  private func onFinish() {
    isLoading = false
  }
}

struct AsyncImage: View {
  @StateObject private var loader: ImageLoader
  private let image: (UIImage) -> Image
  
  init(
    url: URL,
    @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
  ) {
    self.image = image
    _loader = StateObject(wrappedValue: ImageLoader(url: url))
  }
  
  var body: some View {
    VStack {
      switch loader.image {
      case let .some(uiImage):
        image(uiImage)
          .resizable()
      case nil:
        ProgressView()
      }
    }
    .onAppear(perform: loader.load)
  }
  
}
