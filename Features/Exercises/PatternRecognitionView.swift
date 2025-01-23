import SwiftUI

struct PatternRecognitionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PatternRecognitionViewModel()
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Pattern Recognition")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Complete the sequence")
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
                
                // Pattern Display
                VStack(spacing: 30) {
                    // Sequence
                    HStack(spacing: 15) {
                        ForEach(viewModel.pattern.sequence, id: \.self) { number in
                            NumberBox(number: number)
                        }
                        
                        QuestionBox()
                    }
                    
                    // Options
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(viewModel.pattern.options, id: \.self) { option in
                            AnswerButton(
                                number: option,
                                isSelected: viewModel.selectedAnswer == option,
                                action: { viewModel.selectAnswer(option) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Submit Button
                if viewModel.selectedAnswer != nil {
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
            
            // Result Overlay
            if viewModel.showingResult {
                ResultOverlay(
                    isCorrect: viewModel.isCorrect,
                    score: viewModel.lastScore,
                    onNext: viewModel.nextPattern
                )
            }
        }
        .onAppear {
            viewModel.startExercise()
        }
    }
}

// MARK: - Supporting Views
struct NumberBox: View {
    let number: Int
    
    var body: some View {
        Text("\(number)")
            .font(.title)
            .fontWeight(.bold)
            .frame(width: 60, height: 60)
            .background(Color("Primary").opacity(0.2))
            .cornerRadius(10)
    }
}

struct QuestionBox: View {
    var body: some View {
        Text("?")
            .font(.title)
            .fontWeight(.bold)
            .frame(width: 60, height: 60)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
    }
}

struct AnswerButton: View {
    let number: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(isSelected ? Color("Primary") : Color.white.opacity(0.1))
                .cornerRadius(10)
        }
    }
}

struct ResultOverlay: View {
    let isCorrect: Bool
    let score: Int
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isCorrect ? .green : .red)
                
                Text(isCorrect ? "Correct!" : "Try Again")
                    .font(.title)
                    .fontWeight(.bold)
                
                if isCorrect {
                    Text("+\(score) points")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Button(action: onNext) {
                    Text("Next Pattern")
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
class PatternRecognitionViewModel: ObservableObject {
    @Published var pattern: CognitiveExerciseService.Pattern = .init(sequence: [], nextNumber: 0, options: [])
    @Published var selectedAnswer: Int?
    @Published var score = 0
    @Published var currentStreak = 0
    @Published var showingResult = false
    @Published var isCorrect = false
    @Published var lastScore = 0
    
    private let exerciseService = CognitiveExerciseService.shared
    private var difficulty: CognitiveExerciseService.Difficulty = .beginner
    
    func startExercise() {
        generateNewPattern()
    }
    
    func generateNewPattern() {
        pattern = exerciseService.generatePattern(difficulty: difficulty)
        selectedAnswer = nil
        showingResult = false
    }
    
    func selectAnswer(_ number: Int) {
        selectedAnswer = number
    }
    
    func checkAnswer() {
        guard let answer = selectedAnswer else { return }
        
        isCorrect = answer == pattern.nextNumber
        
        if isCorrect {
            currentStreak += 1
            lastScore = exerciseService.calculateScore(
                exerciseType: .patternRecognition,
                difficulty: difficulty,
                accuracy: 1.0
            )
            score += lastScore
            
            // Increase difficulty if performing well
            if currentStreak >= 3 && difficulty != .advanced {
                difficulty = .intermediate // Progress to next difficulty
                currentStreak = 0
            }
        } else {
            currentStreak = 0
            lastScore = 0
            
            // Decrease difficulty if struggling
            if difficulty != .beginner {
                difficulty = .beginner
            }
        }
        
        showingResult = true
    }
    
    func nextPattern() {
        generateNewPattern()
    }
}

// MARK: - Preview
struct PatternRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        PatternRecognitionView()
            .preferredColorScheme(.dark)
    }
} 