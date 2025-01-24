import CoreData
import SwiftUI

class OfflineStorage {
    static let shared = OfflineStorage()
    
    private let container: NSPersistentContainer
    private let containerName = "AttntivData"
    private let feedItemEntityName = "FeedItemEntity"
    private let challengeEntityName = "ChallengeEntity"
    private let achievementEntityName = "AchievementEntity"
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: containerName)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading Core Data: \(error)")
            }
        }
        
        // Merge changes from parent contexts automatically
        context.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Feed Items
    func saveFeedItems(_ items: [FeedItem]) throws {
        // Clear existing items
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: feedItemEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        // Save new items
        for item in items {
            let entity = NSEntityDescription.insertNewObject(forEntityName: feedItemEntityName, into: context)
            entity.setValue(item.id.uuidString, forKey: "id")
            entity.setValue(item.title, forKey: "title")
            entity.setValue(item.content, forKey: "content")
            entity.setValue(item.category, forKey: "category")
            entity.setValue(item.additionalContent, forKey: "additionalContent")
        }
        
        try context.save()
    }
    
    func fetchFeedItems() throws -> [FeedItem] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: feedItemEntityName)
        let results = try context.fetch(fetchRequest) as! [NSManagedObject]
        
        return results.compactMap { object in
            guard let id = object.value(forKey: "id") as? String,
                  let title = object.value(forKey: "title") as? String,
                  let content = object.value(forKey: "content") as? String,
                  let category = object.value(forKey: "category") as? String else {
                return nil
            }
            
            return FeedItem(
                id: UUID(uuidString: id) ?? UUID(),
                title: title,
                content: content,
                category: category,
                backgroundColor: .purple.opacity(0.3),
                additionalContent: object.value(forKey: "additionalContent") as? String
            )
        }
    }
    
    // MARK: - Challenges
    func saveChallenges(_ challenges: [Challenge]) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: challengeEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        for challenge in challenges {
            let entity = NSEntityDescription.insertNewObject(forEntityName: challengeEntityName, into: context)
            entity.setValue(challenge.id.uuidString, forKey: "id")
            entity.setValue(challenge.title, forKey: "title")
            entity.setValue(challenge.description, forKey: "description")
            entity.setValue(challenge.points, forKey: "points")
            entity.setValue(challenge.icon, forKey: "icon")
            entity.setValue(challenge.isCompleted, forKey: "isCompleted")
        }
        
        try context.save()
    }
    
    func fetchChallenges() throws -> [Challenge] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: challengeEntityName)
        let results = try context.fetch(fetchRequest) as! [NSManagedObject]
        
        return results.compactMap { object in
            guard let id = object.value(forKey: "id") as? String,
                  let title = object.value(forKey: "title") as? String,
                  let description = object.value(forKey: "description") as? String,
                  let points = object.value(forKey: "points") as? Int,
                  let icon = object.value(forKey: "icon") as? String,
                  let isCompleted = object.value(forKey: "isCompleted") as? Bool else {
                return nil
            }
            
            return Challenge(
                id: UUID(uuidString: id) ?? UUID(),
                title: title,
                description: description,
                points: points,
                icon: icon,
                isCompleted: isCompleted
            )
        }
    }
    
    // MARK: - Achievements
    func saveAchievements(_ achievements: [Achievement]) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: achievementEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        
        for achievement in achievements {
            let entity = NSEntityDescription.insertNewObject(forEntityName: achievementEntityName, into: context)
            entity.setValue(achievement.id.uuidString, forKey: "id")
            entity.setValue(achievement.title, forKey: "title")
            entity.setValue(achievement.description, forKey: "description")
            entity.setValue(achievement.icon, forKey: "icon")
            entity.setValue(achievement.isUnlocked, forKey: "isUnlocked")
        }
        
        try context.save()
    }
    
    func fetchAchievements() throws -> [Achievement] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: achievementEntityName)
        let results = try context.fetch(fetchRequest) as! [NSManagedObject]
        
        return results.compactMap { object in
            guard let id = object.value(forKey: "id") as? String,
                  let title = object.value(forKey: "title") as? String,
                  let description = object.value(forKey: "description") as? String,
                  let icon = object.value(forKey: "icon") as? String,
                  let isUnlocked = object.value(forKey: "isUnlocked") as? Bool else {
                return nil
            }
            
            return Achievement(
                id: UUID(uuidString: id) ?? UUID(),
                title: title,
                description: description,
                icon: icon,
                isUnlocked: isUnlocked
            )
        }
    }
    
    // MARK: - Sync
    func syncWithBackend() async throws {
        // Fetch offline changes
        let challenges = try fetchChallenges()
        let achievements = try fetchAchievements()
        
        // Upload to Firebase
        for challenge in challenges {
            try await FirebaseService.shared.updateChallenge(challenge)
        }
        
        // Download latest data
        if let userId = Auth.auth().currentUser?.uid {
            let latestChallenges = try await FirebaseService.shared.fetchChallenges(for: userId)
            try saveChallenges(latestChallenges)
        }
    }
} 