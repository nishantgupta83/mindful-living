import SwiftUI

struct LoginView: View {
  @StateObject var authManager = AuthManager.shared
  @State private var email = ""
  @State private var password = ""
  @State private var isSignUp = false
  @State private var errorMessage: String?
  @State private var showError = false

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [
          Color.lavender.opacity(0.1),
          Color.mintGreen.opacity(0.1),
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 24) {
        VStack(spacing: 8) {
          Image(systemName: "leaf.fill")
            .font(.system(size: 48))
            .foregroundColor(.lavender)

          Text("Mindful Living")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.deepLavender)
        }
        .padding(.top, 40)

        VStack(spacing: 16) {
          TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lavender.opacity(0.3), lineWidth: 1))

          SecureField("Password", text: $password)
            .textContentType(.password)
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.lavender.opacity(0.3), lineWidth: 1))
        }

        Button(action: handleAuth) {
          if authManager.isLoading {
            ProgressView()
              .tint(.white)
          } else {
            Text(isSignUp ? "Sign Up" : "Sign In")
              .font(.system(size: 16, weight: .semibold))
          }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(Color.lavender)
        .foregroundColor(.white)
        .cornerRadius(12)
        .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)

        Button(action: { isSignUp.toggle() }) {
          Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
            .font(.system(size: 14))
            .foregroundColor(.lavender)
        }

        Spacer()
      }
      .padding(24)
    }
    .alert("Error", isPresented: $showError) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(errorMessage ?? "An error occurred")
    }
  }

  private func handleAuth() {
    Task {
      do {
        if isSignUp {
          try await authManager.signUp(email: email, password: password)
        } else {
          try await authManager.signIn(email: email, password: password)
        }
      } catch {
        errorMessage = error.localizedDescription
        showError = true
      }
    }
  }
}

#Preview {
  LoginView()
}
