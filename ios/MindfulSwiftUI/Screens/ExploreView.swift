import SwiftUI

struct ExploreView: View {
  @StateObject private var viewModel = ExploreViewModel()
  @State private var searchText = ""
  @State private var selectedCategory: String?
  @State private var selectedDilemma: DilemmaItem?

  var filteredDilemmas: [DilemmaItem] {
    viewModel.dilemmas.filter { dilemma in
      let matchesSearch = searchText.isEmpty ||
        dilemma.title.localizedCaseInsensitiveContains(searchText) ||
        dilemma.description.localizedCaseInsensitiveContains(searchText)

      let matchesCategory = selectedCategory == nil || dilemma.category == selectedCategory
      return matchesSearch && matchesCategory
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        LinearGradient(
          gradient: Gradient(colors: [.lavender.opacity(0.05), .white]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 16) {
          // Search Bar
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.mutedGray)

            TextField("Search situations...", text: $searchText)
              .textFieldStyle(.roundedBorder)

            if !searchText.isEmpty {
              Button(action: { searchText = "" }) {
                Image(systemName: "xmark.circle.fill")
                  .foregroundColor(.mutedGray)
              }
            }
          }
          .padding(12)
          .background(Color.white)
          .cornerRadius(12)
          .padding(.horizontal, 16)

          // Categories
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              CategoryChip(
                title: "All",
                isSelected: selectedCategory == nil,
                action: { selectedCategory = nil }
              )

              ForEach(viewModel.categories, id: \.self) { category in
                CategoryChip(
                  title: category,
                  isSelected: selectedCategory == category,
                  action: { selectedCategory = category }
                )
              }
            }
            .padding(.horizontal, 16)
          }

          // Dilemmas List
          if filteredDilemmas.isEmpty {
            VStack(spacing: 16) {
              Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.lavender.opacity(0.5))

              Text("No situations found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepLavender)

              Text("Try a different search or category")
                .font(.system(size: 14))
                .foregroundColor(.lightGray)
            }
            .frame(maxHeight: .infinity)
            .padding()
          } else {
            ScrollView {
              VStack(spacing: 12) {
                ForEach(filteredDilemmas) { dilemma in
                  NavigationLink(value: dilemma) {
                    DilemmaCardView(dilemma: dilemma)
                  }
                }
              }
              .padding(16)
            }
          }
        }
        .navigationDestination(for: DilemmaItem.self) { dilemma in
          DilemmaDetailView(dilemma: dilemma)
        }
      }
      .navigationTitle("Explore")
    }
  }
}

struct CategoryChip: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(isSelected ? .white : .deepLavender)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.lavender : Color.white)
        .cornerRadius(20)
        .overlay(
          RoundedRectangle(cornerRadius: 20)
            .stroke(Color.lavender.opacity(0.3), lineWidth: isSelected ? 0 : 1)
        )
    }
  }
}

struct DilemmaCardView: View {
  let dilemma: DilemmaItem

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(dilemma.title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.deepCharcoal)
            .lineLimit(1)

          HStack(spacing: 8) {
            Label(dilemma.category, systemImage: "tag.fill")
              .font(.system(size: 12))
              .foregroundColor(.lavender)

            Spacer()

            Text(dilemma.difficulty)
              .font(.system(size: 12, weight: .semibold))
              .foregroundColor(.orange)
          }
        }

        Spacer()

        Image(systemName: "chevron.right")
          .foregroundColor(.lavender)
      }

      Text(dilemma.description)
        .font(.system(size: 13))
        .foregroundColor(.mutedGray)
        .lineLimit(2)
    }
    .padding(16)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
  }
}

#Preview {
  ExploreView()
}
