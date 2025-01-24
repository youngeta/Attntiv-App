import SwiftUI

struct ExercisesView: View {
    @StateObject private var viewModel = ExercisesViewModel()
    @State private var selectedExercise: Exercise?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Daily Progress
                        ProgressSection(progress: viewModel.dailyProgress)
                        
                        // Exercise Categories
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 20
                        ) {
                            ForEach(viewModel.exercises) { exercise in
                                ExerciseCard(exercise: exercise)
                                    .onTapGesture {
                                        selectedExercise = exercise
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Brain Training")
            .sheet(item: $selectedExercise) { exercise in
                exerciseView(for: exercise)
            }
        }
    }
    
    @ViewBuilder
    private func exerciseView(for exercise: Exercise) -> some View {
        switch exercise.type {
        case .memory:
            MemoryExerciseView()
        case .patternRecognition:
            PatternRecognitionView()
        case .focus:
            FocusExerciseView()
        case .problemSolving:
            ProblemSolvingView()
        case .speedProcessing:
            SpeedProcessingView()
        }
    }
}

// MARK: - Supporting Views
struct ProgressSection: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Daily Progress")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color("Primary"), style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    ))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 120, height: 120)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: exercise.icon)
                .font(.system(size: 30))
                .foregroundColor(Color("Primary"))
                .frame(width: 60, height: 60)
                .background(Color("Primary").opacity(0.2))
                .clipShape(Circle())
            
            Text(exercise.title)
                .font(.headline)
            
            Text(exercise.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let bestScore = exercise.bestScore {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("\(bestScore)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - Placeholder Views
struct FocusExerciseView: View {
    var body: some View {
        Text("Focus Exercise")
    }
}

struct ProblemSolvingView: View {
    var body: some View {
        Text("Problem Solving")
    }
}

struct SpeedProcessingView: View {
    var body: some View {
        Text("Speed Processing")
    }
}

// MARK: - Models
struct Exercise: Identifiable {
    let id = UUID()
    let type: CognitiveExerciseService.ExerciseType
    let title: String
    let description: String
    let icon: String
    var bestScore: Int?
    
    static let all: [Exercise] = [
        Exercise(
            type: .memory,
            title: "Memory",
            description: "Train your memory with sequence recall",
            icon: "brain.head.profile",
            bestScore: nil
        ),
        Exercise(
            type: .patternRecognition,
            title: "Patterns",
            description: "Identify and complete patterns",
            icon: "square.grid.3x3.fill",
            bestScore: nil
        ),
        Exercise(
            type: .focus,
            title: "Focus",
            description: "Improve concentration and attention",
            icon: "scope",
            bestScore: nil
        ),
        Exercise(
            type: .problemSolving,
            title: "Problem Solving",
            description: "Enhance logical thinking",
            icon: "puzzlepiece.fill",
            bestScore: nil
        ),
        Exercise(
            type: .speedProcessing,
            title: "Speed",
            description: "Boost mental processing speed",
            icon: "bolt.fill",
            bestScore: nil
        )
    ]
}

// MARK: - View Model
class ExercisesViewModel: ObservableObject {
    @Published var exercises: [Exercise] = Exercise.all
    @Published var dailyProgress: Double = 0.0
    
    private let exerciseService = CognitiveExerciseService.shared
    
    init() {
        loadProgress()
    }
    
    private func loadProgress() {
        // In a real app, this would load from UserDefaults or backend
        dailyProgress = 0.6
    }
}

// MARK: - Preview
struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
            .preferredColorScheme(.dark)
    }
} 