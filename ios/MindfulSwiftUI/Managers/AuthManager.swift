import Foundation
import FirebaseAuth

class AuthManager: NSObject, ObservableObject {
  static let shared = AuthManager()

  @Published var isLoggedIn = false
  @Published var currentUser: User?
  @Published var isLoading = false

  override init() {
    super.init()
    setupAuthStateListener()
  }

  private func setupAuthStateListener() {
    Auth.auth().addStateDidChangeListener { [weak self] _, user in
      DispatchQueue.main.async {
        self?.currentUser = user
        self?.isLoggedIn = user != nil
      }
    }
  }

  func signIn(email: String, password: String) async throws {
    isLoading = true
    defer { isLoading = false }
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    DispatchQueue.main.async {
      self.currentUser = result.user
      self.isLoggedIn = true
    }
  }

  func signUp(email: String, password: String) async throws {
    isLoading = true
    defer { isLoading = false }
    let result = try await Auth.auth().createUser(withEmail: email, password: password)
    DispatchQueue.main.async {
      self.currentUser = result.user
      self.isLoggedIn = true
    }
  }

  func signOut() throws {
    try Auth.auth().signOut()
    DispatchQueue.main.async {
      self.currentUser = nil
      self.isLoggedIn = false
    }
  }
}
