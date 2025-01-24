import SwiftUI
import Combine

class CognitiveExerciseService {
    static let shared = CognitiveExerciseService()
    
    // Exercise Categories
    enum ExerciseType: String, CaseIterable {
        case memory = "Memory"
        case focus = "Focus"
        case problemSolving = "Problem Solving"
        case patternRecognition = "Pattern Recognition"
        case speedProcessing = "Speed Processing"
    }
    
    // Exercise Difficulty
    enum Difficulty: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var multiplier: Double {
            switch self {
            case .beginner: return 1.0
            case .intermediate: return 1.5
            case .advanced: return 2.0
            }
        }
    }
    
    // MARK: - Memory Exercises
    func generateMemorySequence(difficulty: Difficulty) -> [Int] {
        let length: Int
        switch difficulty {
        case .beginner: length = 4
        case .intermediate: length = 6
        case .advanced: length = 8
        }
        
        return (0..<length).map { _ in Int.random(in: 1...9) }
    }
    
    func generatePatternMatrix(size: Int) -> [[Bool]] {
        var matrix = Array(repeating: Array(repeating: false, count: size), count: size)
        let numberOfActiveCells = Int(Double(size * size) * 0.4)
        
        var activeCells = 0
        while activeCells < numberOfActiveCells {
            let row = Int.random(in: 0..<size)
            let col = Int.random(in: 0..<size)
            if !matrix[row][col] {
                matrix[row][col] = true
                activeCells += 1
            }
        }
        
        return matrix
    }
    
    // MARK: - Focus Exercises
    func generateNBackSequence(n: Int, length: Int) -> [Int] {
        var sequence = [Int]()
        for _ in 0..<length {
            if sequence.count >= n && Double.random(in: 0...1) > 0.7 {
                // 30% chance to repeat a number from n positions back
                sequence.append(sequence[sequence.count - n])
            } else {
                sequence.append(Int.random(in: 1...9))
            }
        }
        return sequence
    }
    
    // MARK: - Problem Solving
    struct MathProblem {
        let question: String
        let answer: Int
        let options: [Int]
    }
    
    func generateMathProblem(difficulty: Difficulty) -> MathProblem {
        let operations: [(Int, Int) -> Int] = [
            (+), (-), (*)]
        let symbols = ["+", "-", "×"]
        
        let range: ClosedRange<Int>
        switch difficulty {
        case .beginner: range = 1...10
        case .intermediate: range = 1...20
        case .advanced: range = 1...50
        }
        
        let num1 = Int.random(in: range)
        let num2 = Int.random(in: range)
        let operationIndex = Int.random(in: 0..<operations.count)
        
        let answer = operations[operationIndex](num1, num2)
        let question = "\(num1) \(symbols[operationIndex]) \(num2)"
        
        // Generate wrong options
        var options = Set<Int>()
        options.insert(answer)
        while options.count < 4 {
            let offset = Int.random(in: -5...5)
            if offset != 0 {
                options.insert(answer + offset)
            }
        }
        
        return MathProblem(
            question: question,
            answer: answer,
            options: Array(options).shuffled()
        )
    }
    
    // MARK: - Pattern Recognition
    struct Pattern {
        let sequence: [Int]
        let nextNumber: Int
        let options: [Int]
    }
    
    func generatePattern(difficulty: Difficulty) -> Pattern {
        let patterns: [(Int) -> Int] = [
            { $0 + 2 },     // +2
            { $0 * 2 },     // ×2
            { $0 + $0 },    // Double
            { $0 * $0 }     // Square
        ]
        
        let length: Int
        switch difficulty {
        case .beginner: length = 4
        case .intermediate: length = 6
        case .advanced: length = 8
        }
        
        let start = Int.random(in: 1...10)
        let pattern = patterns.randomElement()!
        
        var sequence = [start]
        for _ in 1..<length {
            sequence.append(pattern(sequence.last!))
        }
        
        let nextNumber = pattern(sequence.last!)
        
        // Generate wrong options
        var options = Set<Int>()
        options.insert(nextNumber)
        while options.count < 4 {
            let offset = Int.random(in: -5...5)
            if offset != 0 {
                options.insert(nextNumber + offset)
            }
        }
        
        return Pattern(
            sequence: sequence,
            nextNumber: nextNumber,
            options: Array(options).shuffled()
        )
    }
    
    // MARK: - Speed Processing
    struct SpeedChallenge {
        let symbols: [String]
        let target: String
        let timeLimit: TimeInterval
    }
    
    func generateSpeedChallenge(difficulty: Difficulty) -> SpeedChallenge {
        let symbols = ["⭐️", "🌟", "💫", "✨", "⚡️", "🌙", "☀️", "🌎", "🌍", "🌏"]
        let count: Int
        let timeLimit: TimeInterval
        
        switch difficulty {
        case .beginner:
            count = 12
            timeLimit = 5.0
        case .intermediate:
            count = 20
            timeLimit = 4.0
        case .advanced:
            count = 30
            timeLimit = 3.0
        }
        
        let target = symbols.randomElement()!
        var challengeSymbols = [String]()
        
        // Add target symbol multiple times
        let targetCount = Int.random(in: 3...6)
        for _ in 0..<targetCount {
            challengeSymbols.append(target)
        }
        
        // Fill the rest with random symbols
        while challengeSymbols.count < count {
            if let symbol = symbols.randomElement(), symbol != target {
                challengeSymbols.append(symbol)
            }
        }
        
        return SpeedChallenge(
            symbols: challengeSymbols.shuffled(),
            target: target,
            timeLimit: timeLimit
        )
    }
    
    // MARK: - Score Calculation
    func calculateScore(
        exerciseType: ExerciseType,
        difficulty: Difficulty,
        accuracy: Double,
        timeBonus: TimeInterval = 0
    ) -> Int {
        let baseScore: Int
        switch exerciseType {
        case .memory:
            baseScore = 100
        case .focus:
            baseScore = 150
        case .problemSolving:
            baseScore = 200
        case .patternRecognition:
            baseScore = 175
        case .speedProcessing:
            baseScore = 125
        }
        
        let difficultyMultiplier = difficulty.multiplier
        let accuracyMultiplier = accuracy
        let timeBonusPoints = Int(timeBonus * 10)
        
        return Int(Double(baseScore) * difficultyMultiplier * accuracyMultiplier) + timeBonusPoints
    }
} 