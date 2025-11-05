import SwiftUI

struct DashboardView: View {
  @StateObject private var viewModel = DashboardViewModel()

  var body: some View {
    NavigationStack {
      ZStack {
        LinearGradient(
          gradient: Gradient(colors: [.lavender.opacity(0.05), .white]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
          VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
              Text("Welcome Back")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.deepLavender)

              Text("Your daily wellness journey")
                .font(.system(size: 14))
                .foregroundColor(.lightGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)

            // Wellness Score
            VStack(spacing: 12) {
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text("Wellness Score")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.lightGray)

                  Text("\(Int(viewModel.wellnessScore))/100")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.deepLavender)
                }

                Spacer()

                ZStack {
                  Circle()
                    .stroke(Color.lavender.opacity(0.2), lineWidth: 8)

                  Circle()
                    .trim(from: 0, to: CGFloat(viewModel.wellnessScore) / 100)
                    .stroke(Color.lavender, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                  VStack {
                    Image(systemName: "checkmark.circle.fill")
                      .font(.system(size: 24))
                      .foregroundColor(.mintGreen)
                  }
                }
                .frame(width: 80, height: 80)
              }
              .padding(20)
              .background(Color.white)
              .cornerRadius(16)
              .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)

            // Quick Stats
            VStack(spacing: 12) {
              HStack(spacing: 12) {
                StatCard(
                  icon: "flame.fill",
                  title: "Streak",
                  value: "\(viewModel.streak) days",
                  color: .orange
                )

                StatCard(
                  icon: "heart.fill",
                  title: "Mood",
                  value: viewModel.currentMood,
                  color: .pink
                )
              }

              HStack(spacing: 12) {
                StatCard(
                  icon: "book.fill",
                  title: "Entries",
                  value: "\(viewModel.journalEntries)",
                  color: .blue
                )

                StatCard(
                  icon: "sparkles",
                  title: "Practices",
                  value: "\(viewModel.completedPractices)",
                  color: .purple
                )
              }
            }
            .padding(.horizontal, 20)

            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
              Text("Quick Actions")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.deepLavender)
                .padding(.horizontal, 20)

              HStack(spacing: 12) {
                QuickActionButton(
                  icon: "book",
                  title: "Journal",
                  color: .blue
                )

                QuickActionButton(
                  icon: "wind",
                  title: "Breathe",
                  color: .lavender
                )

                QuickActionButton(
                  icon: "moon.stars",
                  title: "Meditate",
                  color: .purple
                )
              }
              .padding(.horizontal, 20)
            }

            Spacer()
              .frame(height: 20)
          }
          .padding(.vertical, 20)
        }
      }
      .navigationTitle("Dashboard")
    }
  }
}

struct StatCard: View {
  let icon: String
  let title: String
  let value: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 18, weight: .semibold))
          .foregroundColor(color)
          .frame(width: 36, height: 36)
          .background(color.opacity(0.1))
          .cornerRadius(8)

        Spacer()
      }

      Text(title)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(.lightGray)

      Text(value)
        .font(.system(size: 18, weight: .bold))
        .foregroundColor(.deepCharcoal)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
  }
}

struct QuickActionButton: View {
  let icon: String
  let title: String
  let color: Color

  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.system(size: 24))
        .foregroundColor(color)

      Text(title)
        .font(.system(size: 12, weight: .semibold))
        .foregroundColor(.deepCharcoal)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 100)
    .background(color.opacity(0.08))
    .cornerRadius(12)
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.2), lineWidth: 1))
  }
}

#Preview {
  DashboardView()
}
