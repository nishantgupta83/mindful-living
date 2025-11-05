import SwiftUI

struct PracticesView: View {
  @StateObject private var viewModel = PracticesViewModel()

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
              Text("Guided Practices")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.deepLavender)

              Text("Enhance your wellness routine")
                .font(.system(size: 14))
                .foregroundColor(.lightGray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)

            // Categories
            VStack(spacing: 20) {
              ForEach(viewModel.practices) { practice in
                NavigationLink(destination: PracticeDetailView(practice: practice)) {
                  PracticeCardView(practice: practice)
                }
              }
            }
            .padding(.horizontal, 20)

            Spacer()
              .frame(height: 20)
          }
          .padding(.vertical, 20)
        }
      }
      .navigationTitle("Practices")
    }
  }
}

struct PracticeCardView: View {
  let practice: Practice

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        VStack(alignment: .leading, spacing: 8) {
          Text(practice.name)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)

          Text(practice.description)
            .font(.system(size: 13))
            .foregroundColor(.white.opacity(0.9))
            .lineLimit(2)

          HStack(spacing: 16) {
            Label(String(practice.duration) + " min", systemImage: "clock")
              .font(.system(size: 12))
              .foregroundColor(.white.opacity(0.8))

            Label(practice.difficulty, systemImage: "gauge")
              .font(.system(size: 12))
              .foregroundColor(.white.opacity(0.8))
          }
        }

        Spacer()

        VStack {
          Image(systemName: practice.icon)
            .font(.system(size: 36))
            .foregroundColor(.white.opacity(0.9))
        }
      }
      .padding(20)
      .background(
        LinearGradient(
          gradient: Gradient(colors: [practice.color, practice.color.opacity(0.7)]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
      .cornerRadius(16)
      .overlay(RoundedRectangle(cornerRadius: 16).stroke(practice.color.opacity(0.5), lineWidth: 1))
    }
  }
}

struct PracticeDetailView: View {
  @Environment(\.dismiss) var dismiss
  let practice: Practice
  @State private var isPlaying = false

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [practice.color.opacity(0.1), .white]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          HStack {
            Button(action: { dismiss() }) {
              Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(practice.color)
                .frame(width: 40, height: 40)
            }

            Spacer()

            Image(systemName: practice.icon)
              .font(.system(size: 28))
              .foregroundColor(practice.color)
          }

          // Title and description
          VStack(alignment: .leading, spacing: 12) {
            Text(practice.name)
              .font(.system(size: 28, weight: .bold))
              .foregroundColor(.deepCharcoal)

            Text(practice.description)
              .font(.system(size: 16))
              .foregroundColor(.mutedGray)
              .lineSpacing(2)

            HStack(spacing: 16) {
              Label(String(practice.duration) + " min", systemImage: "clock")
                .font(.system(size: 13))
                .foregroundColor(.deepLavender)

              Label(practice.difficulty, systemImage: "gauge")
                .font(.system(size: 13))
                .foregroundColor(.deepLavender)
            }
          }

          // Benefits
          VStack(alignment: .leading, spacing: 12) {
            Text("Benefits")
              .font(.system(size: 16, weight: .semibold))
              .foregroundColor(.deepCharcoal)

            VStack(alignment: .leading, spacing: 8) {
              ForEach(practice.benefits, id: \.self) { benefit in
                HStack(spacing: 10) {
                  Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(practice.color)

                  Text(benefit)
                    .font(.system(size: 14))
                    .foregroundColor(.deepCharcoal)
                }
              }
            }
          }

          // Start Practice Button
          Button(action: { isPlaying.toggle() }) {
            HStack {
              Image(systemName: isPlaying ? "pause.fill" : "play.fill")
              Text(isPlaying ? "Pause" : "Start Practice")
                .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(practice.color)
            .foregroundColor(.white)
            .cornerRadius(14)
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
  PracticesView()
}
