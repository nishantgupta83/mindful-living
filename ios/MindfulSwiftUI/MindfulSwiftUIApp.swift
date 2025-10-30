import SwiftUI
import Firebase

@main
struct MindfulSwiftUIApp: App {
  @StateObject var authManager = AuthManager.shared
  @State private var isInitializing = true

  init() {
    FirebaseApp.configure()
  }

  var body: some Scene {
    WindowGroup {
      if isInitializing {
        SplashView()
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              isInitializing = false
            }
          }
      } else if authManager.isLoggedIn {
        TabView {
          DashboardView()
            .tabItem {
              Label("Home", systemImage: "house.fill")
            }

          ExploreView()
            .tabItem {
              Label("Explore", systemImage: "magnifyingglass")
            }

          JournalView()
            .tabItem {
              Label("Journal", systemImage: "book.fill")
            }

          PracticesView()
            .tabItem {
              Label("Practices", systemImage: "sparkles")
            }

          ProfileView()
            .tabItem {
              Label("Profile", systemImage: "person.fill")
            }
        }
        .accentColor(.lavender)
      } else {
        LoginView()
      }
    }
  }
}

// MARK: - Splash View
struct SplashView: View {
  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [.lavender.opacity(0.1), .mintGreen.opacity(0.1)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 20) {
        Image(systemName: "leaf.fill")
          .font(.system(size: 60))
          .foregroundColor(.lavender)

        Text("Mindful Living")
          .font(.system(size: 28, weight: .bold))
          .foregroundColor(.deepLavender)

        Text("Daily Wellness Guidance")
          .font(.system(size: 16))
          .foregroundColor(.lightGray)
      }
    }
  }
}

// MARK: - Color Extensions
extension Color {
  static let lavender = Color(red: 0.74, green: 0.56, blue: 0.89)
  static let deepLavender = Color(red: 0.57, green: 0.35, blue: 0.82)
  static let mintGreen = Color(red: 0.49, green: 0.83, blue: 0.65)
  static let deepCharcoal = Color(red: 0.15, green: 0.15, blue: 0.15)
  static let lightGray = Color(red: 0.85, green: 0.85, blue: 0.85)
  static let mutedGray = Color(red: 0.65, green: 0.65, blue: 0.65)
}
