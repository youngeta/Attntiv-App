import SwiftUI

@main
struct AttntivApp: App {
    // MARK: - Properties
    @StateObject private var appState = AppState()
    
    // MARK: - Theme Colors
    private let primaryColor = Color("Primary") // Purple
    private let backgroundColor = Color("Background") // Black
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedTab: Tab = .feed
    
    enum Tab {
        case feed
        case challenges
        case profile
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    var username: String
    var email: String
    var points: Int
    var badges: [Badge]
    var preferences: UserPreferences
    
    struct UserPreferences: Codable {
        var interests: [String]
        var notificationsEnabled: Bool
    }
}

struct Badge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let imageURL: String
} 