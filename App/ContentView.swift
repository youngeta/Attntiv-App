import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if !appState.isAuthenticated {
                AuthenticationView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CognitiveFeedView()
                .tabItem {
                    Label("Feed", systemImage: "brain.head.profile")
                }
                .tag(AppState.Tab.feed)
            
            GamificationBoardView()
                .tabItem {
                    Label("Challenges", systemImage: "trophy.fill")
                }
                .tag(AppState.Tab.challenges)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)
        }
        .accentColor(Color("Primary"))
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
}

// MARK: - Placeholder Views
struct AuthenticationView: View {
    var body: some View {
        Text("Authentication View")
    }
}

struct CognitiveFeedView: View {
    var body: some View {
        Text("Cognitive Feed")
    }
}

struct GamificationBoardView: View {
    var body: some View {
        Text("Gamification Board")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
} 