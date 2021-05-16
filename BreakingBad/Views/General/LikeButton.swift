import SwiftUI

struct LikeButton: View {
  @Binding private(set) var isLiked: Bool
  
  var body: some View {
    Button(action: {
      self.isLiked.toggle()
    }) {
      Image(systemName: self.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
        .imageScale(.large)
    }
  }
}
