import SwiftUI

struct MemoryExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MemoryExerciseViewModel()
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Memory Training")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Remember the sequence")
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
                
                if viewModel.isShowingSequence {
                    // Display sequence
                    SequenceDisplayView(numbers: viewModel.sequence)
                } else if viewModel.isInputting {
                    // Input pad
                    NumberInputPad(
                        input: $viewModel.userInput,
                        isEnabled: !viewModel.isChecking
                    )
                } else {
                    // Results
                    ResultView(
                        isCorrect: viewModel.isCorrect,
                        score: viewModel.lastScore,
                        onNext: viewModel.startNewRound
                    )
                }
                
                Spacer()
                
                // Controls
                if !viewModel.isShowingSequence && viewModel.isInputting {
                    Button(action: viewModel.checkAnswer) {
                        Text("Check Answer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("Primary"))
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.userInput.isEmpty || viewModel.isChecking)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.startExercise()
        }
    }
}

// MARK: - Supporting Views
struct ScoreView: View {
    let score: Int
    
    var body: some View {
        VStack {
            Text("\(score)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Score")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct StreakView: View {
    let streak: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(streak)")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            Text("Streak")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct SequenceDisplayView: View {
    let numbers: [Int]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("\(numbers[currentIndex])")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(Color("Primary"))
                .transition(.scale.combined(with: .opacity))
                .id(currentIndex)
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(0..<numbers.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentIndex ? Color("Primary") : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .onAppear {
            animateSequence()
        }
    }
    
    private func animateSequence() {
        guard currentIndex < numbers.count - 1 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                currentIndex += 1
            }
            animateSequence()
        }
    }
}

struct NumberInputPad: View {
    @Binding var input: String
    let isEnabled: Bool
    
    private let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["←", "0", "→"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            Text(input.isEmpty ? "Enter the sequence" : input)
                .font(.title)
                .fontWeight(.bold)
                .frame(height: 50)
            
            ForEach(numbers, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            handleInput(number)
                        }) {
                            Text(number)
                                .font(.title)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .disabled(!isEnabled)
                    }
                }
            }
        }
        .padding()
    }
    
    private func handleInput(_ number: String) {
        switch number {
        case "←":
            if !input.isEmpty {
                input.removeLast()
            }
        case "→":
            break // Could be used for submitting
        default:
            input.append(number)
        }
    }
}

struct ResultView: View {
    let isCorrect: Bool
    let score: Int
    let onNext: () -> Void
    
    var body: some View {
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

// MARK: - View Model
class MemoryExerciseViewModel: ObservableObject {
    @Published var sequence: [Int] = []
    @Published var userInput = ""
    @Published var score = 0
    @Published var currentStreak = 0
    @Published var isShowingSequence = false
    @Published var isInputting = false
    @Published var isChecking = false
    @Published var isCorrect = false
    @Published var lastScore = 0
    
    private let exerciseService = CognitiveExerciseService.shared
    private var difficulty: CognitiveExerciseService.Difficulty = .beginner
    
    func startExercise() {
        startNewRound()
    }
    
    func startNewRound() {
        sequence = exerciseService.generateMemorySequence(difficulty: difficulty)
        userInput = ""
        isShowingSequence = true
        isInputting = false
        isChecking = false
        
        // Hide sequence after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(sequence.count + 1)) {
            withAnimation {
                self.isShowingSequence = false
                self.isInputting = true
            }
        }
    }
    
    func checkAnswer() {
        isChecking = true
        
        let correct = userInput == sequence.map(String.init).joined()
        isCorrect = correct
        
        if correct {
            currentStreak += 1
            lastScore = exerciseService.calculateScore(
                exerciseType: .memory,
                difficulty: difficulty,
                accuracy: 1.0
            )
            score += lastScore
            
            // Increase difficulty if performing well
            if currentStreak >= 3 && difficulty != .advanced {
                difficulty = CognitiveExerciseService.Difficulty(rawValue: difficulty.rawValue)! // Move to next difficulty
                currentStreak = 0
            }
        } else {
            currentStreak = 0
            lastScore = 0
            
            // Decrease difficulty if struggling
            if difficulty != .beginner {
                difficulty = CognitiveExerciseService.Difficulty(rawValue: difficulty.rawValue)! // Move to previous difficulty
            }
        }
        
        isInputting = false
    }
}

// MARK: - Preview
struct MemoryExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryExerciseView()
            .preferredColorScheme(.dark)
    }
} 