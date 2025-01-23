import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseService {
    static let shared = FirebaseService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Authentication
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        let user = try await fetchUser(id: result.user.uid)
        return user
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        let user = User(
            id: result.user.uid,
            username: username,
            email: email,
            points: 0,
            badges: [],
            preferences: .init(interests: [], notificationsEnabled: true)
        )
        
        try await saveUser(user)
        return user
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - User Data
    func fetchUser(id: String) async throws -> User {
        let document = try await db.collection("users").document(id).getDocument()
        return try document.data(as: User.self)
    }
    
    func saveUser(_ user: User) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    func updateUserPoints(_ userId: String, points: Int) async throws {
        try await db.collection("users").document(userId).updateData([
            "points": points
        ])
    }
    
    // MARK: - Feed Items
    func saveFeedItem(_ item: FeedItem, userId: String) async throws {
        var feedItem = item
        feedItem.userId = userId
        try db.collection("feedItems").document().setData(from: feedItem)
    }
    
    func fetchFeedItems() async throws -> [FeedItem] {
        let snapshot = try await db.collection("feedItems")
            .order(by: "timestamp", descending: true)
            .limit(to: 20)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: FeedItem.self)
        }
    }
    
    // MARK: - Challenges
    func fetchChallenges(for userId: String) async throws -> [Challenge] {
        let snapshot = try await db.collection("challenges")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Challenge.self)
        }
    }
    
    func updateChallenge(_ challenge: Challenge) async throws {
        guard let id = challenge.id else { return }
        try db.collection("challenges").document(id).setData(from: challenge)
    }
    
    // MARK: - Achievements
    func unlockAchievement(_ achievement: Achievement, for userId: String) async throws {
        let ref = db.collection("users").document(userId)
        try await ref.updateData([
            "badges": FieldValue.arrayUnion([achievement])
        ])
    }
    
    // MARK: - Social Features
    func followUser(_ userId: String, followingId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "following": FieldValue.arrayUnion([followingId])
        ])
    }
    
    func unfollowUser(_ userId: String, followingId: String) async throws {
        try await db.collection("users").document(userId).updateData([
            "following": FieldValue.arrayRemove([followingId])
        ])
    }
    
    func shareFeedItem(_ item: FeedItem, userId: String) async throws {
        var sharedItem = item
        sharedItem.sharedBy = userId
        sharedItem.sharedAt = Date()
        try db.collection("sharedItems").document().setData(from: sharedItem)
    }
}

// MARK: - Models Extension
extension FeedItem {
    var userId: String?
    var sharedBy: String?
    var sharedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, content, category, backgroundColor, additionalContent
        case userId, sharedBy, sharedAt
    }
} 