import SwiftUI

struct ProblemSolvingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProblemSolvingViewModel()
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Problem Solving")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Math & Logic")
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
                
                // Timer
                TimerView(
                    timeRemaining: viewModel.timeRemaining,
                    totalTime: viewModel.totalTime
                )
                
                Spacer()
                
                // Problem Display
                if let problem = viewModel.currentProblem {
                    VStack(spacing: 30) {
                        // Question
                        Text(problem.question)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("Primary").opacity(0.2))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        
                        // Options
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 20
                        ) {
                            ForEach(problem.options, id: \.self) { option in
                                AnswerButton(
                                    number: option,
                                    isSelected: viewModel.selectedAnswer == option,
                                    action: { viewModel.selectAnswer(option) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
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
            
            // Results Overlay
            if viewModel.showingResults {
                ResultsOverlay(
                    score: viewModel.roundScore,
                    timeBonus: viewModel.timeBonus,
                    correctAnswers: viewModel.correctAnswers,
                    totalProblems: viewModel.totalProblems,
                    onNext: viewModel.startNewRound
                )
            }
        }
        .onAppear {
            viewModel.startExercise()
        }
    }
}

// MARK: - Supporting Views
struct TimerView: View {
    let timeRemaining: TimeInterval
    let totalTime: TimeInterval
    
    private var progress: Double {
        timeRemaining / totalTime
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    Rectangle()
                        .fill(timerColor)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
            .padding(.horizontal)
            
            // Time Display
            Text(timeString)
                .font(.caption)
                .foregroundColor(timerColor)
        }
    }
    
    private var timeString: String {
        let seconds = Int(timeRemaining)
        return "\(seconds)s"
    }
    
    private var timerColor: Color {
        if progress > 0.5 {
            return .green
        } else if progress > 0.25 {
            return .yellow
        } else {
            return .red
        }
    }
}

struct ResultsOverlay: View {
    let score: Int
    let timeBonus: Int
    let correctAnswers: Int
    let totalProblems: Int
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Round Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    ScoreRow(title: "Base Score", value: score - timeBonus)
                    ScoreRow(title: "Time Bonus", value: timeBonus)
                    Divider()
                    ScoreRow(title: "Total Score", value: score)
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                
                Text("\(correctAnswers)/\(totalProblems) Correct")
                    .font(.headline)
                    .foregroundColor(
                        Double(correctAnswers) / Double(totalProblems) >= 0.7
                            ? .green : .yellow
                    )
                
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

struct ScoreRow: View {
    let title: String
    let value: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("+\(value)")
                .fontWeight(.bold)
        }
    }
}

// MARK: - View Model
class ProblemSolvingViewModel: ObservableObject {
    @Published var score = 0
    @Published var currentStreak = 0
    @Published var currentProblem: CognitiveExerciseService.MathProblem?
    @Published var selectedAnswer: Int?
    @Published var timeRemaining: TimeInterval = 30
    @Published var showingResults = false
    @Published var roundScore = 0
    @Published var timeBonus = 0
    @Published var correctAnswers = 0
    
    let totalTime: TimeInterval = 30
    let totalProblems = 5
    
    private let exerciseService = CognitiveExerciseService.shared
    private var difficulty: CognitiveExerciseService.Difficulty = .beginner
    private var timer: Timer?
    private var problemCount = 0
    
    func startExercise() {
        startNewRound()
    }
    
    func startNewRound() {
        problemCount = 0
        correctAnswers = 0
        roundScore = 0
        timeBonus = 0
        showingResults = false
        generateNewProblem()
    }
    
    private func generateNewProblem() {
        currentProblem = exerciseService.generateMathProblem(difficulty: difficulty)
        selectedAnswer = nil
        timeRemaining = totalTime
        startTimer()
    }
    
    func selectAnswer(_ answer: Int) {
        selectedAnswer = answer
    }
    
    func checkAnswer() {
        guard let problem = currentProblem,
              let answer = selectedAnswer else { return }
        
        let isCorrect = answer == problem.answer
        
        if isCorrect {
            correctAnswers += 1
            currentStreak += 1
            
            // Calculate score with time bonus
            let baseScore = exerciseService.calculateScore(
                exerciseType: .problemSolving,
                difficulty: difficulty,
                accuracy: 1.0
            )
            timeBonus = Int(timeRemaining * 10)
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
        
        problemCount += 1
        
        if problemCount >= totalProblems {
            endRound()
        } else {
            generateNewProblem()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            checkAnswer()
        }
    }
    
    private func endRound() {
        timer?.invalidate()
        timer = nil
        score += roundScore
        showingResults = true
    }
}

// MARK: - Preview
struct ProblemSolvingView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemSolvingView()
            .preferredColorScheme(.dark)
    }
} 