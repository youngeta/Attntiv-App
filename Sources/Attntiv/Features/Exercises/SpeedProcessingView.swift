import SwiftUI

struct SpeedProcessingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SpeedProcessingViewModel()
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Speed Processing")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Visual Processing")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Score and Progress
                HStack(spacing: 40) {
                    ScoreView(score: viewModel.score)
                    StreakView(streak: viewModel.currentStreak)
                }
                
                Spacer()
                
                // Challenge Display
                if let challenge = viewModel.currentChallenge {
                    VStack(spacing: 30) {
                        // Instructions
                        Text(challenge.instruction)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        // Visual Elements
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible()), count: 3),
                            spacing: 20
                        ) {
                            ForEach(0..<9, id: \.self) { index in
                                VisualElement(
                                    symbol: challenge.symbols[index],
                                    isTarget: challenge.targetSymbols.contains(challenge.symbols[index]),
                                    isSelected: viewModel.selectedIndices.contains(index),
                                    action: { viewModel.toggleSelection(index) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Submit Button
                if !viewModel.selectedIndices.isEmpty {
                    Button(action: viewModel.checkAnswer) {
                        Text("Submit Answer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("Primary"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Results Overlay
            if viewModel.showingResults {
                ResultsOverlay(
                    score: viewModel.roundScore,
                    timeBonus: viewModel.timeBonus,
                    correctAnswers: viewModel.correctAnswers,
                    totalProblems: viewModel.totalChallenges,
                    onNext: viewModel.startNewRound
                )
            }
            
            // Countdown Overlay
            if viewModel.showingCountdown {
                CountdownOverlay(
                    countdown: viewModel.countdown,
                    instruction: "Get Ready!"
                )
            }
        }
        .onAppear {
            viewModel.startExercise()
        }
    }
}

// MARK: - Supporting Views
struct VisualElement: View {
    let symbol: String
    let isTarget: Bool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 80, height: 80)
                
                Text(symbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color("Primary")
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

struct CountdownOverlay: View {
    let countdown: Int
    let instruction: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(instruction)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(countdown)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(Color("Primary"))
            }
        }
    }
}

// MARK: - View Model
class SpeedProcessingViewModel: ObservableObject {
    @Published var score = 0
    @Published var currentStreak = 0
    @Published var currentChallenge: CognitiveExerciseService.SpeedChallenge?
    @Published var selectedIndices: Set<Int> = []
    @Published var showingResults = false
    @Published var roundScore = 0
    @Published var timeBonus = 0
    @Published var correctAnswers = 0
    @Published var showingCountdown = false
    @Published var countdown = 3
    
    let totalChallenges = 5
    private let exerciseService = CognitiveExerciseService.shared
    private var difficulty: CognitiveExerciseService.Difficulty = .beginner
    private var challengeCount = 0
    private var countdownTimer: Timer?
    private var startTime: Date?
    
    func startExercise() {
        startNewRound()
    }
    
    func startNewRound() {
        challengeCount = 0
        correctAnswers = 0
        roundScore = 0
        timeBonus = 0
        showingResults = false
        startCountdown()
    }
    
    private func startCountdown() {
        showingCountdown = true
        countdown = 3
        
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                self.countdownTimer?.invalidate()
                self.showingCountdown = false
                self.generateNewChallenge()
            }
        }
    }
    
    private func generateNewChallenge() {
        currentChallenge = exerciseService.generateSpeedChallenge(difficulty: difficulty)
        selectedIndices.removeAll()
        startTime = Date()
    }
    
    func toggleSelection(_ index: Int) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
    }
    
    func checkAnswer() {
        guard let challenge = currentChallenge,
              let start = startTime else { return }
        
        // Calculate response time
        let responseTime = Date().timeIntervalSince(start)
        
        // Check if selected symbols match target symbols
        let selectedSymbols = Set(selectedIndices.map { challenge.symbols[$0] })
        let isCorrect = selectedSymbols == Set(challenge.targetSymbols)
        
        if isCorrect {
            correctAnswers += 1
            currentStreak += 1
            
            // Calculate score with time bonus
            let baseScore = exerciseService.calculateScore(
                exerciseType: .speedProcessing,
                difficulty: difficulty,
                accuracy: 1.0
            )
            
            // Time bonus decreases as response time increases
            let maxBonusTime: TimeInterval = 3.0
            let bonusMultiplier = max(0, 1 - (responseTime / maxBonusTime))
            timeBonus = Int(Double(baseScore) * bonusMultiplier)
            roundScore += baseScore + timeBonus
            
            // Increase difficulty if performing well
            if currentStreak >= 3 && difficulty != .advanced {
                difficulty = .intermediate
                currentStreak = 0
            }
        } else {
            currentStreak = 0
            
            // Decrease difficulty if struggling
            if difficulty != .beginner {
                difficulty = .beginner
            }
        }
        
        challengeCount += 1
        
        if challengeCount >= totalChallenges {
            endRound()
        } else {
            generateNewChallenge()
        }
    }
    
    private func endRound() {
        score += roundScore
        showingResults = true
    }
}

// MARK: - Preview
struct SpeedProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedProcessingView()
            .preferredColorScheme(.dark)
    }
} 