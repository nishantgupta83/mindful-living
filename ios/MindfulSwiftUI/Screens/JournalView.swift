import SwiftUI

struct JournalView: View {
  @StateObject private var viewModel = JournalViewModel()
  @State private var showingNewEntry = false

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
          if viewModel.entries.isEmpty {
            VStack(spacing: 24) {
              Image(systemName: "book.circle")
                .font(.system(size: 64))
                .foregroundColor(.lavender.opacity(0.5))

              VStack(spacing: 8) {
                Text("No entries yet")
                  .font(.system(size: 18, weight: .semibold))
                  .foregroundColor(.deepLavender)

                Text("Start your wellness journey by writing your first entry")
                  .font(.system(size: 14))
                  .foregroundColor(.lightGray)
                  .multilineTextAlignment(.center)
              }

              Button(action: { showingNewEntry = true }) {
                HStack {
                  Image(systemName: "plus")
                  Text("New Entry")
                    .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.lavender)
                .foregroundColor(.white)
                .cornerRadius(12)
              }
              .padding(.horizontal, 40)
            }
            .frame(maxHeight: .infinity)
            .padding()
          } else {
            ScrollView {
              VStack(spacing: 12) {
                HStack {
                  Text("Entries")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.deepCharcoal)

                  Spacer()

                  Button(action: { showingNewEntry = true }) {
                    Image(systemName: "plus.circle.fill")
                      .font(.system(size: 20))
                      .foregroundColor(.lavender)
                  }
                }
                .padding(.horizontal, 16)

                ForEach(viewModel.entries) { entry in
                  JournalEntryCardView(entry: entry)
                }
              }
              .padding(.vertical, 16)
            }
          }
        }
      }
      .navigationTitle("Journal")
      .sheet(isPresented: $showingNewEntry) {
        NewJournalEntryView(isPresented: $showingNewEntry) { entryText in
          viewModel.addEntry(content: entryText)
        }
      }
    }
  }
}

struct JournalEntryCardView: View {
  let entry: JournalEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(entry.title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.deepCharcoal)

          Text(entry.date.formatted(date: .abbreviated, time: .omitted))
            .font(.system(size: 12))
            .foregroundColor(.lightGray)
        }

        Spacer()

        HStack(spacing: 4) {
          Image(systemName: "heart.fill")
            .font(.system(size: 12))
            .foregroundColor(.pink)

          Text(entry.mood)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.deepCharcoal)
        }
      }

      Text(entry.content)
        .font(.system(size: 13))
        .foregroundColor(.mutedGray)
        .lineLimit(3)
        .lineSpacing(1.5)
    }
    .padding(16)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    .padding(.horizontal, 16)
  }
}

struct NewJournalEntryView: View {
  @Binding var isPresented: Bool
  let onSave: (String) -> Void
  @State private var entryText = ""

  var body: some View {
    NavigationStack {
      ZStack {
        Color(.systemBackground)
          .ignoresSafeArea()

        VStack(spacing: 16) {
          TextEditor(text: $entryText)
            .frame(minHeight: 300)
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lavender.opacity(0.3), lineWidth: 1))

          Button(action: {
            onSave(entryText)
            isPresented = false
          }) {
            Text("Save Entry")
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(Color.lavender)
              .foregroundColor(.white)
              .cornerRadius(12)
          }
          .disabled(entryText.trimmingCharacters(in: .whitespaces).isEmpty)

          Spacer()
        }
        .padding(16)
      }
      .navigationTitle("New Entry")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            isPresented = false
          }
          .foregroundColor(.lavender)
        }
      }
    }
  }
}

#Preview {
  JournalView()
}
