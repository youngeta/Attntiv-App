import SwiftUI

struct GamificationBoardView: View {
    @StateObject private var viewModel = GamificationViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Stats Overview
                        StatsOverview(stats: viewModel.userStats)
                        
                        // Daily Challenges
                        VStack(alignment: .leading) {
                            Text("Daily Challenges")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.dailyChallenges) { challenge in
                                        ChallengeCard(challenge: challenge)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Achievements
                        VStack(alignment: .leading) {
                            Text("Achievements")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                ForEach(viewModel.achievements) { achievement in
                                    AchievementCard(achievement: achievement)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.refreshChallenges()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct StatsOverview: View {
    let stats: UserStats
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                StatItem(title: "Points", value: "\(stats.points)", icon: "star.fill")
                StatItem(title: "Streak", value: "\(stats.streak) days", icon: "flame.fill")
                StatItem(title: "Rank", value: stats.rank, icon: "trophy.fill")
            }
            
            ProgressBar(progress: stats.dailyProgress)
                .frame(height: 8)
                .padding(.horizontal)
        }
        .padding()
        .background(Color("Primary").opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("Primary"))
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                
                Rectangle()
                    .foregroundColor(Color("Primary"))
                    .frame(width: geometry.size.width * progress)
            }
            .cornerRadius(4)
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(systemName: challenge.icon)
                .font(.title)
                .foregroundColor(Color("Primary"))
            
            Text(challenge.title)
                .font(.headline)
            
            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("\(challenge.points) pts")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("Primary").opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? Color("Primary") : .gray)
            
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}

// MARK: - View Model
class GamificationViewModel: ObservableObject {
    @Published var userStats = UserStats(
        points: 1250,
        streak: 5,
        rank: "Gold",
        dailyProgress: 0.7
    )
    
    @Published var dailyChallenges: [Challenge] = [
        Challenge(
            title: "Memory Master",
            description: "Complete 3 memory exercises",
            points: 100,
            icon: "brain.head.profile",
            isCompleted: true
        ),
        Challenge(
            title: "Focus Champion",
            description: "Maintain focus for 20 minutes",
            points: 150,
            icon: "scope",
            isCompleted: false
        ),
        Challenge(
            title: "Knowledge Seeker",
            description: "Learn 5 new facts",
            points: 120,
            icon: "book.fill",
            isCompleted: false
        )
    ]
    
    @Published var achievements: [Achievement] = [
        Achievement(
            title: "First Steps",
            description: "Complete your first challenge",
            icon: "figure.walk",
            isUnlocked: true
        ),
        Achievement(
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            icon: "calendar",
            isUnlocked: false
        ),
        Achievement(
            title: "Mind Master",
            description: "Score 1000 points",
            icon: "brain",
            isUnlocked: true
        ),
        Achievement(
            title: "Social Butterfly",
            description: "Share 5 insights",
            icon: "person.2.fill",
            isUnlocked: false
        )
    ]
    
    func refreshChallenges() {
        // Simulate refreshing challenges
        // In a real app, this would fetch new challenges from the backend
    }
}

// MARK: - Models
struct UserStats {
    let points: Int
    let streak: Int
    let rank: String
    let dailyProgress: Double
}

struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let points: Int
    let icon: String
    var isCompleted: Bool
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
}

// MARK: - Preview
struct GamificationBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GamificationBoardView()
            .preferredColorScheme(.dark)
    }
} 