import SwiftUI

struct ErrorView: View {
  
  let error: String
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "exclamationmark.circle")
        .imageScale(.large)
      Text(error)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .padding()
    .foregroundColor(.white)
    .background(Color.red)
    .cornerRadius(8)
  }
}

// MARK: - Preview
struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: "Oops something went wrong")
  }
}
