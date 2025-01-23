import SwiftUI

struct FocusExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FocusExerciseViewModel()
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Focus Training")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("N-Back Challenge")
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
                
                // N-Back Level
                Text("N-Back Level: \(viewModel.nBackLevel)")
                    .font(.headline)
                    .padding(.vertical)
                
                Spacer()
                
                // Current Number Display
                if viewModel.isPlaying {
                    NumberDisplay(
                        number: viewModel.currentNumber,
                        isMatch: viewModel.showingMatch
                    )
                }
                
                Spacer()
                
                // Controls
                if viewModel.isPlaying {
                    HStack(spacing: 40) {
                        // Match Button
                        ActionButton(
                            title: "Match",
                            icon: "checkmark.circle.fill",
                            color: .green
                        ) {
                            viewModel.checkMatch(userSaysMatch: true)
                        }
                        
                        // No Match Button
                        ActionButton(
                            title: "No Match",
                            icon: "xmark.circle.fill",
                            color: .red
                        ) {
                            viewModel.checkMatch(userSaysMatch: false)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Start Button
                    Button(action: viewModel.startRound) {
                        Text("Start Round")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color("Primary"))
                            .cornerRadius(10)
                    }
                }
            }
            
            // Results Overlay
            if viewModel.showingResults {
                ResultsOverlay(
                    score: viewModel.roundScore,
                    accuracy: viewModel.accuracy,
                    onNext: viewModel.startRound
                )
            }
        }
    }
}

// MARK: - Supporting Views
struct NumberDisplay: View {
    let number: Int
    let isMatch: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("Primary").opacity(0.2))
                .frame(width: 150, height: 150)
            
            Text("\(number)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(isMatch ? .green : Color("Primary"))
                .transition(.scale.combined(with: .opacity))
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(color)
            .frame(width: 120, height: 80)
            .background(color.opacity(0.2))
            .cornerRadius(15)
        }
    }
}

struct ResultsOverlay: View {
    let score: Int
    let accuracy: Double
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Round Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 10) {
                    Text("Score: \(score)")
                        .font(.headline)
                    
                    Text("Accuracy: \(Int(accuracy * 100))%")
                        .font(.headline)
                        .foregroundColor(
                            accuracy >= 0.8 ? .green :
                            accuracy >= 0.6 ? .yellow : .red
                        )
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                Button(action: onNext) {
                    Text("Next Round")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color("Primary"))
                        .cornerRadius(10)
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - View Model
class FocusExerciseViewModel: ObservableObject {
    @Published var score = 0
    @Published var currentStreak = 0
    @Published var nBackLevel = 2
    @Published var currentNumber = 0
    @Published var isPlaying = false
    @Published var showingMatch = false
    @Published var showingResults = false
    @Published var roundScore = 0
    @Published var accuracy = 0.0
    
    private let exerciseService = CognitiveExerciseService.shared
    private var sequence: [Int] = []
    private var currentIndex = 0
    private var correctAnswers = 0
    private var totalAnswers = 0
    private var difficulty: CognitiveExerciseService.Difficulty = .beginner
    
    func startRound() {
        sequence = exerciseService.generateNBackSequence(n: nBackLevel, length: 20)
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        isPlaying = true
        showNextNumber()
    }
    
    private func showNextNumber() {
        guard currentIndex < sequence.count else {
            endRound()
            return
        }
        
        currentNumber = sequence[currentIndex]
        showingMatch = false
        
        // Show next number after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.currentIndex += 1
            self?.showNextNumber()
        }
    }
    
    func checkMatch(userSaysMatch: Bool) {
        guard currentIndex >= nBackLevel else { return }
        
        let actualMatch = sequence[currentIndex] == sequence[currentIndex - nBackLevel]
        let isCorrect = userSaysMatch == actualMatch
        
        if isCorrect {
            correctAnswers += 1
            currentStreak += 1
            showingMatch = actualMatch
        } else {
            currentStreak = 0
        }
        
        totalAnswers += 1
    }
    
    private func endRound() {
        isPlaying = false
        accuracy = Double(correctAnswers) / Double(totalAnswers)
        
        roundScore = exerciseService.calculateScore(
            exerciseType: .focus,
            difficulty: difficulty,
            accuracy: accuracy
        )
        
        score += roundScore
        
        // Adjust difficulty
        if accuracy >= 0.8 && currentStreak >= 3 {
            nBackLevel = min(nBackLevel + 1, 4)
            difficulty = .advanced
        } else if accuracy <= 0.4 {
            nBackLevel = max(nBackLevel - 1, 1)
            difficulty = .beginner
        }
        
        showingResults = true
    }
}

// MARK: - Preview
struct FocusExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        FocusExerciseView()
            .preferredColorScheme(.dark)
    }
} 