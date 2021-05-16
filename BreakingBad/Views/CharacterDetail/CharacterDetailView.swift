import SwiftUI
import Combine

struct CharacterDetailView: View {
  
  enum ActiveSheetId: Identifiable {
    var id: Self { self }
    case showQuotes
    case submitReview
  }
  
  @StateObject private var viewModel: CharacterDetailViewModel
  @State private var activeSheetId: ActiveSheetId?
  
  private let appStore: AppStore
  
  init(
    appStore: AppStore,
    characterDetail: CharacterDetail
  ) {
    self.appStore = appStore
    self._viewModel = StateObject(
      wrappedValue: .init(appStore: appStore,
                          characterDetail: characterDetail)
    )
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        headerView
          .padding()
          .background(Color.gray.opacity(0.1))
          .cornerRadius(12)
        Divider()
        VStack(spacing: 12) {
          detailRow(title: "Occupation",
                    detail: viewModel.detail.character.occupationText)
          detailRow(title: "Category",
                    detail: viewModel.detail.character.category)
          detailRow(title: "Seasons",
                    detail: viewModel.detail.character.appearancesText)
          detailRow(title: "Better Call Saul seasons",
                    detail: viewModel.detail.character.betterCallSaulAppearancesText)
          detailRow(title: "Birthday",
                    detail: viewModel.detail.character.birthdayText)
        }
        Divider()
        HStack {
          Button("Show quotes") {
            activeSheetId = .showQuotes
          }
          Spacer()
          Button("Submit a review") {
            activeSheetId = .submitReview
          }
        }
        Spacer()
      }
      .padding()
      .navigationBarTitle(viewModel.detail.character.name, displayMode: .inline)
      .navigationBarItems(
        trailing: LikeButton(isLiked: $viewModel.detail.isLiked)
      )
      .sheet(item: $activeSheetId, content: { sheetId in
        NavigationView {
          sheetView(for: sheetId)
        }
      })
    }
  }
  
  private func detailRow(title: String, detail: String) -> some View {
    HStack(alignment: .top) {
      Text(title)
        .font(.headline)
      Spacer()
      Text(detail.isEmpty ? "N/A" : detail)
        .font(.caption)
        .multilineTextAlignment(.trailing)
    }
    .padding([.top, .bottom], 4)
  }
  
  private var headerView: some View {
    HStack(alignment: .top, spacing: 20) {
      if let url = viewModel.detail.character.imageURL {
        AsyncImage(url: url)
          .scaledToFit()
          .frame(minWidth: 100,
                 maxWidth: 150,
                 minHeight: 100,
                 maxHeight: 150)
          
        VStack(alignment: .leading, spacing: 8) {
          headerItem(title: "Nickname:", value: viewModel.detail.character.nickname)
          headerItem(title: "Actor:", value: viewModel.detail.character.portrayed)
          headerItem(title: "Status:", value: viewModel.detail.character.status)
        }
        Spacer()
      }
    }
  }
  
  private func headerItem(title: String, value: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
      Text(value)
    }
  }
  
  // MARK: - Navigation
  @ViewBuilder private func sheetView(for id: ActiveSheetId) -> some View {
    switch id {
    case.showQuotes:
      QuoteListView(
        appStore: appStore,
        character: viewModel.detail.character,
        onDone: {
          activeSheetId = nil
        }
      )
    case .submitReview:
      SubmitReviewView(
        appStore: appStore,
        onCancel: {
          activeSheetId = nil
        }
      )
    }
  }
}

struct CharacterDetailView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CharacterDetailView(
        appStore: .fake,
        characterDetail: .init(character: .walterWhite, isLiked: true)
      )
    }
  }
}
