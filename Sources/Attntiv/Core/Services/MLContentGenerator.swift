import CoreML
import NaturalLanguage

class MLContentGenerator {
    static let shared = MLContentGenerator()
    private let contentTypes = ["fact", "quiz", "challenge"]
    private let topics = ["memory", "focus", "problem-solving", "creativity", "logic"]
    
    private init() {}
    
    func generateContent() async throws -> FeedItem {
        // In a real app, this would use a trained Core ML model
        // For now, we'll simulate content generation
        let type = contentTypes.randomElement() ?? "fact"
        let topic = topics.randomElement() ?? "memory"
        
        switch type {
        case "fact":
            return generateFact(topic: topic)
        case "quiz":
            return generateQuiz(topic: topic)
        case "challenge":
            return generateChallenge(topic: topic)
        default:
            return generateFact(topic: topic)
        }
    }
    
    private func generateFact(topic: String) -> FeedItem {
        let facts = [
            "memory": [
                "The human brain can store approximately 2.5 petabytes of information",
                "Sleep is crucial for memory consolidation and learning",
                "The hippocampus plays a key role in forming new memories"
            ],
            "focus": [
                "The average attention span is about 8 seconds",
                "Multitasking can reduce productivity by up to 40%",
                "Regular meditation can improve focus and concentration"
            ],
            "problem-solving": [
                "Taking breaks can improve problem-solving abilities",
                "The brain uses about 20% of the body's energy",
                "Creative thinking activates multiple brain regions"
            ]
        ]
        
        let content = facts[topic]?.randomElement() ?? "Did you know? The brain never stops learning."
        
        return FeedItem(
            title: "Brain Fact",
            content: content,
            category: topic.capitalized,
            backgroundColor: .purple.opacity(0.3),
            additionalContent: "Learn more about \(topic) and how it affects your cognitive abilities."
        )
    }
    
    private func generateQuiz(topic: String) -> FeedItem {
        let quizzes = [
            "What percentage of your brain's energy does glucose consumption account for?",
            "How many hours of sleep are recommended for optimal cognitive function?",
            "What is the average attention span of an adult?"
        ]
        
        return FeedItem(
            title: "Brain Quiz",
            content: quizzes.randomElement() ?? "Test your knowledge!",
            category: "Quiz",
            backgroundColor: .blue.opacity(0.3),
            additionalContent: "Answer to earn points and unlock achievements!"
        )
    }
    
    private func generateChallenge(topic: String) -> FeedItem {
        let challenges = [
            "Complete a memory game in under 2 minutes",
            "Maintain focus on a single task for 25 minutes",
            "Solve three logic puzzles consecutively"
        ]
        
        return FeedItem(
            title: "Daily Challenge",
            content: challenges.randomElement() ?? "Challenge yourself!",
            category: "Challenge",
            backgroundColor: .green.opacity(0.3),
            additionalContent: "Complete this challenge to earn bonus points!"
        )
    }
}

// MARK: - Content Analysis
extension MLContentGenerator {
    func analyzeSentiment(for text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let sentiment = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore).0
        return Double(sentiment?.rawValue ?? "0") ?? 0
    }
    
    func extractKeywords(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        
        var keywords: [String] = []
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType) { tag, range in
            if let keyword = text[range].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
                keywords.append(keyword)
            }
            return true
        }
        return keywords
    }
} 