import SwiftUI

struct DilemmaDetailView: View {
  @Environment(\.dismiss) var dismiss
  let dilemma: DilemmaItem
  @State private var isSaved = false

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [.lavender.opacity(0.05), .white]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header with dismiss button
          HStack {
            Button(action: { dismiss() }) {
              Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.lavender)
                .frame(width: 40, height: 40)
            }

            Spacer()

            Button(action: { isSaved.toggle() }) {
              Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.lavender)
                .frame(width: 40, height: 40)
            }
          }

          // Title and metadata
          VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
              Label(dilemma.category, systemImage: "tag.fill")
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.lavender.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.lavender)

              Text(dilemma.difficulty)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
                .foregroundColor(.orange)
            }

            Text(dilemma.title)
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.deepCharcoal)

            Text(dilemma.description)
              .font(.system(size: 16))
              .foregroundColor(.mutedGray)
              .lineSpacing(2)
          }

          // Mindful Approach
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Image(systemName: "leaf.fill")
                .font(.system(size: 20))
                .foregroundColor(.lavender)

              Text("Mindful Approach")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepLavender)

              Spacer()
            }

            Text(dilemma.mindfulApproach)
              .font(.system(size: 14))
              .foregroundColor(.deepCharcoal)
              .lineSpacing(2)
          }
          .padding(16)
          .background(Color.lavender.opacity(0.08))
          .cornerRadius(12)

          // Practical Steps
          VStack(alignment: .leading, spacing: 12) {
            Text("Practical Steps")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.deepCharcoal)

            VStack(spacing: 12) {
              ForEach(Array(dilemma.practicalSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                  ZStack {
                    Circle()
                      .fill(Color.lavender)

                    Text("\(index + 1)")
                      .font(.system(size: 12, weight: .bold))
                      .foregroundColor(.white)
                  }
                  .frame(width: 28, height: 28)
                  .flexibleFrame(minWidth: 28, maxWidth: 28)

                  Text(step)
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal)
                    .lineSpacing(2)

                  Spacer()
                }
              }
            }
          }

          // Action Buttons
          HStack(spacing: 12) {
            Button(action: {}) {
              HStack {
                Image(systemName: "bookmark.fill")
                Text("Save")
                  .font(.system(size: 14, weight: .semibold))
              }
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(Color.lavender)
              .foregroundColor(.white)
              .cornerRadius(12)
            }

            Button(action: {}) {
              HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share")
                  .font(.system(size: 14, weight: .semibold))
              }
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(Color.white)
              .foregroundColor(.lavender)
              .cornerRadius(12)
              .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lavender, lineWidth: 2))
            }
          }

          Spacer()
            .frame(height: 20)
        }
        .padding(20)
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

#Preview {
  DilemmaDetailView(
    dilemma: DilemmaItem(
      id: "1",
      title: "Dealing with stress",
      description: "How to manage pressure",
      category: "Career",
      difficulty: "Medium",
      mindfulApproach: "Practice mindfulness",
      practicalSteps: ["Step 1", "Step 2", "Step 3"]
    )
  )
}

extension View {
  func flexibleFrame(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil) -> some View {
    frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
  }
}
