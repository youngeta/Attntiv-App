import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Header
                        ProfileHeader(
                            username: viewModel.profile.username,
                            email: viewModel.profile.email,
                            avatarURL: viewModel.profile.avatarURL
                        )
                        
                        // Stats Grid
                        StatsGrid(stats: viewModel.profile.stats)
                        
                        // Interests
                        InterestsList(interests: viewModel.profile.interests)
                        
                        // Settings Sections
                        SettingsSections(
                            notifications: $viewModel.profile.notificationsEnabled,
                            darkMode: $viewModel.profile.darkModeEnabled,
                            soundEnabled: $viewModel.profile.soundEnabled
                        )
                        
                        // Sign Out Button
                        Button(action: {
                            viewModel.signOut()
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditProfile.toggle()
                    }) {
                        Image(systemName: "pencil")
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(profile: $viewModel.profile)
            }
        }
    }
}

struct ProfileHeader: View {
    let username: String
    let email: String
    let avatarURL: String?
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color("Primary").opacity(0.2))
                    .frame(width: 100, height: 100)
                
                if avatarURL != nil {
                    // In a real app, load image from URL
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color("Primary"))
                } else {
                    Text(String(username.prefix(1)).uppercased())
                        .font(.title)
                        .foregroundColor(Color("Primary"))
                }
            }
            
            VStack(spacing: 5) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct StatsGrid: View {
    let stats: UserProfileStats
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            StatBox(title: "Points", value: "\(stats.totalPoints)")
            StatBox(title: "Challenges", value: "\(stats.completedChallenges)")
            StatBox(title: "Streak", value: "\(stats.currentStreak)")
        }
        .padding(.horizontal)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct InterestsList: View {
    let interests: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Interests")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(interests, id: \.self) { interest in
                        Text(interest)
                            .font(.subheadline)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color("Primary").opacity(0.2))
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SettingsSections: View {
    @Binding var notifications: Bool
    @Binding var darkMode: Bool
    @Binding var soundEnabled: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            SettingsSection(title: "Preferences") {
                Toggle("Notifications", isOn: $notifications)
                Toggle("Dark Mode", isOn: $darkMode)
                Toggle("Sound Effects", isOn: $soundEnabled)
            }
            
            SettingsSection(title: "About") {
                NavigationLink("Privacy Policy") {
                    Text("Privacy Policy")
                }
                
                NavigationLink("Terms of Service") {
                    Text("Terms of Service")
                }
                
                NavigationLink("Help & Support") {
                    Text("Help & Support")
                }
            }
        }
        .padding(.horizontal)
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
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 0) {
                content
                    .padding()
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct EditProfileView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Username", text: $profile.username)
                    TextField("Email", text: $profile.email)
                }
                
                Section(header: Text("Interests")) {
                    ForEach(profile.interests, id: \.self) { interest in
                        Text(interest)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save profile changes
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model
class ProfileViewModel: ObservableObject {
    @Published var profile = UserProfile(
        username: "JohnDoe",
        email: "john@example.com",
        avatarURL: nil,
        stats: UserProfileStats(
            totalPoints: 1250,
            completedChallenges: 15,
            currentStreak: 5
        ),
        interests: ["Memory Training", "Problem Solving", "Pattern Recognition", "Focus"],
        notificationsEnabled: true,
        darkModeEnabled: true,
        soundEnabled: true
    )
    
    func signOut() {
        // Implement sign out logic
    }
}

// MARK: - Models
struct UserProfile {
    var username: String
    var email: String
    var avatarURL: String?
    var stats: UserProfileStats
    var interests: [String]
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var soundEnabled: Bool
}

struct UserProfileStats {
    var totalPoints: Int
    var completedChallenges: Int
    var currentStreak: Int
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
    }
} 