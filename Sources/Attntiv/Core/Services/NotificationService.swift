import UserNotifications
import FirebaseMessaging

class NotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = NotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        setupNotifications()
    }
    
    func setupNotifications() {
        notificationCenter.delegate = self
        Messaging.messaging().delegate = self
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Push Notifications
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Firebase registration token: \(token)")
        
        // Send this token to your server to enable push notifications
        Task {
            try await updateDeviceToken(token)
        }
    }
    
    private func updateDeviceToken(_ token: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        try await FirebaseService.shared.db.collection("users").document(userId).updateData([
            "deviceToken": token
        ])
    }
    
    // MARK: - Local Notifications
    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    func scheduleDailyReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time for Brain Training!"
        content.body = "Complete today's challenges to maintain your streak."
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You're on a roll! Complete today's challenge to keep your streak going."
        content.sound = .default
        
        // Schedule for 8 PM if user hasn't completed daily challenge
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streakReminder", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    // MARK: - Achievement Notifications
    func notifyAchievementUnlocked(_ achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(achievement.title): \(achievement.description)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - Social Notifications
    func notifyNewFollower(username: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Follower!"
        content.body = "\(username) started following you"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    func notifySharedContent(username: String) {
        let content = UNMutableNotificationContent()
        content.title = "Content Shared"
        content.body = "\(username) shared your content"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        handleNotificationResponse(identifier)
        completionHandler()
    }
    
    private func handleNotificationResponse(_ identifier: String) {
        // Handle different notification types
        switch identifier {
        case "dailyReminder":
            // Navigate to challenges
            NotificationCenter.default.post(name: .showChallenges, object: nil)
        case "streakReminder":
            // Navigate to current challenge
            NotificationCenter.default.post(name: .showCurrentChallenge, object: nil)
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showChallenges = Notification.Name("showChallenges")
    static let showCurrentChallenge = Notification.Name("showCurrentChallenge")
} 