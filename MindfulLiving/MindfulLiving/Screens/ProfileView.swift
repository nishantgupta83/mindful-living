import SwiftUI

struct ProfileView: View {
  @StateObject var authManager = AuthManager.shared
  @State private var showingSignOutAlert = false

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
          VStack(spacing: 24) {
            // User Profile Header
            VStack(spacing: 12) {
              Image(systemName: "person.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.lavender)

              if let user = authManager.currentUser {
                Text(user.displayName ?? user.email ?? "User")
                  .font(.system(size: 20, weight: .semibold))
                  .foregroundColor(.deepCharcoal)

                Text(user.email ?? "")
                  .font(.system(size: 13))
                  .foregroundColor(.lightGray)
              }
            }
            .padding(.vertical, 20)

            // Settings Sections
            SettingsSection(title: "Preferences") {
              SettingRow(icon: "moon.stars.fill", label: "Dark Mode", color: .purple, toggle: .constant(false))
              SettingRow(icon: "textformat.size", label: "Text Size", color: .blue, toggle: .constant(false))
            }

            SettingsSection(title: "Wellness") {
              SettingRow(icon: "air.fill", label: "Breathing Reminders", color: .green, toggle: .constant(true))
              SettingRow(icon: "music.note.fill", label: "Background Music", color: .orange, toggle: .constant(true))
            }

            SettingsSection(title: "Support") {
              SettingRowAction(icon: "info.circle.fill", label: "About", color: .blue)
              SettingRowAction(icon: "questionmark.circle.fill", label: "Help", color: .green)
            }

            // Sign Out Button
            Button(action: { showingSignOutAlert = true }) {
              HStack {
                Image(systemName: "arrowtriang.left.fill")
                  .font(.system(size: 14, weight: .semibold))

                Text("Sign Out")
                  .font(.system(size: 16, weight: .semibold))
              }
              .frame(maxWidth: .infinity)
              .frame(height: 44)
              .background(Color.red.opacity(0.1))
              .foregroundColor(.red)
              .cornerRadius(12)
            }
            .padding(.horizontal, 20)

            Spacer()
              .frame(height: 20)
          }
          .padding(.vertical, 20)
        }
      }
      .navigationTitle("Profile")
      .alert("Sign Out", isPresented: $showingSignOutAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Sign Out", role: .destructive) {
          try? authManager.signOut()
        }
      } message: {
        Text("Are you sure you want to sign out?")
      }
    }
  }
}

struct SettingsSection<Content: View>: View {
  let title: String
  let content: Content

  init(title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.lightGray)
        .padding(.horizontal, 20)

      VStack(spacing: 0) {
        content
      }
      .background(Color.white)
      .cornerRadius(12)
      .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
      .padding(.horizontal, 20)
    }
  }
}

struct SettingRow: View {
  let icon: String
  let label: String
  let color: Color
  @Binding var toggle: Bool

  var body: some View {
    HStack {
      Image(systemName: icon)
        .font(.system(size: 16))
        .foregroundColor(color)
        .frame(width: 30)

      Text(label)
        .font(.system(size: 16))
        .foregroundColor(.deepCharcoal)

      Spacer()

      Toggle("", isOn: $toggle)
    }
    .padding(16)
    .borderBottom()
  }
}

struct SettingRowAction: View {
  let icon: String
  let label: String
  let color: Color

  var body: some View {
    HStack {
      Image(systemName: icon)
        .font(.system(size: 16))
        .foregroundColor(color)
        .frame(width: 30)

      Text(label)
        .font(.system(size: 16))
        .foregroundColor(.deepCharcoal)

      Spacer()

      Image(systemName: "chevron.right")
        .font(.system(size: 14))
        .foregroundColor(.mutedGray)
    }
    .padding(16)
    .contentShape(Rectangle())
    .borderBottom()
  }
}

extension View {
  func borderBottom() -> some View {
    VStack {
      self
      Divider()
        .padding(.leading, 46)
    }
  }
}

#Preview {
  ProfileView()
}
