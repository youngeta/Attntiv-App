import SwiftUI
import Combine

class CognitiveFeedViewModel: ObservableObject {
    @Published var feedItems: [FeedItem] = []
    @Published var currentIndex: UUID = UUID()
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let mlGenerator = MLContentGenerator.shared
    private let firebaseService = FirebaseService.shared
    private let offlineStorage = OfflineStorage.shared
    
    init() {
        // Setup network monitoring
        NotificationCenter.default
            .publisher(for: .connectivityStatusChanged)
            .sink { [weak self] _ in
                self?.handleConnectivityChange()
            }
            .store(in: &cancellables)
    }
    
    func loadFeedItems() {
        Task {
            await loadContent()
        }
    }
    
    private func loadContent() async {
        isLoading = true
        error = nil
        
        do {
            if NetworkMonitor.shared.isConnected {
                // Online: Load from Firebase and ML
                async let remoteItems = firebaseService.fetchFeedItems()
                async let generatedItem = mlGenerator.generateContent()
                
                var items = try await [generatedItem] + remoteItems
                
                // Save to offline storage
                try offlineStorage.saveFeedItems(items)
                
                await MainActor.run {
                    self.feedItems = items
                    self.currentIndex = items.first?.id ?? UUID()
                }
            } else {
                // Offline: Load from Core Data
                let items = try offlineStorage.fetchFeedItems()
                
                await MainActor.run {
                    self.feedItems = items
                    self.currentIndex = items.first?.id ?? UUID()
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load content: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func likeFeedItem(_ item: FeedItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                // Update in Firebase
                try await firebaseService.saveFeedItem(item, userId: userId)
                
                // Update offline storage
                var updatedItems = feedItems
                if let index = updatedItems.firstIndex(where: { $0.id == item.id }) {
                    updatedItems[index] = item
                }
                try offlineStorage.saveFeedItems(updatedItems)
                
                // Analyze content for personalization
                let sentiment = mlGenerator.analyzeSentiment(for: item.content)
                let keywords = mlGenerator.extractKeywords(from: item.content)
                
                // Use this data to improve content generation
                print("Content sentiment: \(sentiment)")
                print("Keywords: \(keywords)")
            } catch {
                self.error = "Failed to save like: \(error.localizedDescription)"
            }
        }
    }
    
    func shareFeedItem(_ item: FeedItem) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Task {
            do {
                try await firebaseService.shareFeedItem(item, userId: userId)
                NotificationService.shared.scheduleLocalNotification(
                    title: "Content Shared",
                    body: "Your content has been shared with your followers",
                    timeInterval: 1
                )
            } catch {
                self.error = "Failed to share content: \(error.localizedDescription)"
            }
        }
    }
    
    private func handleConnectivityChange() {
        if NetworkMonitor.shared.isConnected {
            // Sync offline changes when connection is restored
            Task {
                do {
                    try await offlineStorage.syncWithBackend()
                    await loadContent()
                } catch {
                    self.error = "Failed to sync: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Network Monitoring
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private(set) var isConnected = true
    
    private init() {
        // In a real app, implement network monitoring using NWPathMonitor
    }
}

extension Notification.Name {
    static let connectivityStatusChanged = Notification.Name("connectivityStatusChanged")
} 