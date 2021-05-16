import SwiftUI
import Combine

struct SubmitReviewView: View {
  
  @StateObject private var viewModel: SubmitReviewViewModel
  
  typealias ActionHandler = () -> Void
  var onCancel: ActionHandler?
  
  init(
    appStore: AppStore,
    onCancel: ActionHandler? = nil
  ) {
    self._viewModel = StateObject(
      wrappedValue: .init(appStore: appStore)
    )
    self.onCancel = onCancel
  }
  
  var body: some View {
    Form {
      if let error = viewModel.error {
        ErrorView(error: error.localizedDescription)
      }
      TextField("Enter your name", text: $viewModel.name)
        .disableAutocorrection(true)
      DatePicker("Date", selection: $viewModel.dateWatched)
      VStack(alignment: .leading) {
        Text("Review")
        TextEditor(text: $viewModel.detail)
      }
      Picker("Rating", selection: $viewModel.rating) {
        ForEach(Array(stride(from: 1, to: 10, by: 1)), id: \.self) { rating in
          Text(String(rating)).tag(rating)
        }
      }
    }
    .navigationTitle("Submit review")
    .navigationBarItems(
      leading: Button("Cancel") {
        onCancel?()        
      },
      trailing: Button("Save") {
        viewModel.save.send()
      }
    )
  }
}

struct ReviewView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      SubmitReviewView(
        appStore: .fake
      )
    }
  }
}
