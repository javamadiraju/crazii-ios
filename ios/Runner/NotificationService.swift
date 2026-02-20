import Foundation
import UIKit
import UserNotifications
import BackgroundTasks

/// iOS equivalent of Android's NotificationService
/// Polls the API for new notifications and displays them
class NotificationService: NSObject {
    
    static let shared = NotificationService()
    
    private let TAG = "FB_NOTIF_SERVICE"
    private let API_URL_TEMPLATE = "https://cgmember.com/api/all-user-notifications/%@"
    private let MARKET_CHANNEL_ID = "MarketNotificationChannel"
    
    // Background task identifier
    static let backgroundTaskIdentifier = "com.example.freebankingapp.notificationPoll"
    
    // Polling timer for foreground
    private var pollingTimer: Timer?
    private let pollingInterval: TimeInterval = 30.0 // 30 seconds
    
    // Date formatter for parsing API timestamps
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private override init() {
        super.init()
        print("[\(TAG)] Service INITIALIZED")
    }
    
    // MARK: - Public Methods
    
    /// Start the notification polling service
    func startService() {
        print("[\(TAG)] Service STARTED")
        
        // Request notification permissions
        requestNotificationPermission()
        
        // Start foreground polling
        startForegroundPolling()
        
        // Register background tasks (iOS 13+)
        if #available(iOS 13.0, *) {
            registerBackgroundTask()
        }
    }
    
    /// Stop the notification polling service
    func stopService() {
        print("[\(TAG)] Service STOPPED")
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    /// Check for notifications immediately
    func checkNotificationsNow(completion: ((Bool) -> Void)? = nil) {
        print("[\(TAG)] Checking notifications NOW...")
        checkMarketNotifications(completion: completion)
    }
    
    // MARK: - Permission Handling
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("[\(self.TAG)] Notification permission GRANTED")
            } else {
                print("[\(self.TAG)] Notification permission DENIED: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    
    // MARK: - Foreground Polling
    
    private func startForegroundPolling() {
        // Wait for user data first
        waitForUserData()
    }
    
    private func waitForUserData() {
        print("[\(TAG)] Waiting for user data...")
        
        let defaults = UserDefaults.standard
        let userJson = defaults.string(forKey: "flutter.user")
        let token = defaults.string(forKey: "flutter.access_token")
        
        print("[\(TAG)] Checking user prefs → user=\(userJson != nil), token=\(token != nil)")
        
        if userJson != nil && token != nil && !token!.isEmpty {
            print("[\(TAG)] User data READY → start polling")
            startPollingTimer()
        } else {
            // Retry after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.waitForUserData()
            }
        }
    }
    
    private func startPollingTimer() {
        // Invalidate existing timer
        pollingTimer?.invalidate()
        
        // Create new timer
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            self?.checkMarketNotifications(completion: nil)
        }
        
        // Fire immediately
        pollingTimer?.fire()
        
        print("[\(TAG)] Polling timer STARTED (interval: \(pollingInterval)s)")
    }
    
    // MARK: - Background Task (iOS 13+)
    
    @available(iOS 13.0, *)
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: NotificationService.backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }
        
        print("[\(TAG)] Background task REGISTERED")
    }
    
    @available(iOS 13.0, *)
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: NotificationService.backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("[\(TAG)] Background task SCHEDULED")
        } catch {
            print("[\(TAG)] Failed to schedule background task: \(error)")
        }
    }
    
    @available(iOS 13.0, *)
    private func handleBackgroundTask(task: BGAppRefreshTask) {
        print("[\(TAG)] Background task RUNNING")
        
        // Schedule the next background task
        scheduleBackgroundTask()
        
        // Set expiration handler
        task.expirationHandler = {
            print("[\(self.TAG)] Background task EXPIRED")
            task.setTaskCompleted(success: false)
        }
        
        // Check for notifications
        checkMarketNotifications { success in
            print("[\(self.TAG)] Background task COMPLETED: \(success)")
            task.setTaskCompleted(success: success)
        }
    }
    
    // MARK: - API Call
    
    private func checkMarketNotifications(completion: ((Bool) -> Void)?) {
        let defaults = UserDefaults.standard
        let userJson = defaults.string(forKey: "flutter.user")
        let accessToken = defaults.string(forKey: "flutter.access_token")
        
        guard let token = accessToken, !token.isEmpty else {
            print("[\(TAG)] Access token missing → skip poll")
            completion?(false)
            return
        }
        
        // Parse user ID from JSON
        var userId = "1"
        if let userJsonData = userJson?.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: userJsonData) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let idUser = data["id_user"] {
                    userId = "\(idUser)"
                }
            } catch {
                print("[\(TAG)] Failed to parse user JSON: \(error)")
            }
        }
        
        let urlString = String(format: API_URL_TEMPLATE, userId)
        print("[\(TAG)] Calling API → \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("[\(TAG)] Invalid URL")
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15.0
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                completion?(false)
                return
            }
            
            if let error = error {
                print("[\(self.TAG)] API FAILURE: \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[\(self.TAG)] Invalid response")
                completion?(false)
                return
            }
            
            guard httpResponse.statusCode == 200, let data = data else {
                print("[\(self.TAG)] API ERROR → code=\(httpResponse.statusCode)")
                completion?(false)
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("[\(self.TAG)] API RESPONSE → \(responseString.prefix(200))...")
                self.parseAndShowNotifications(json: data)
                completion?(true)
            } else {
                completion?(false)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Parse & Display
    
    private func parseAndShowNotifications(json: Data) {
        do {
            guard let root = try JSONSerialization.jsonObject(with: json) as? [String: Any],
                  let notifications = root["notifications"] as? [[String: Any]] else {
                print("[\(TAG)] No notifications array")
                return
            }
            
            let defaults = UserDefaults.standard
            let lastSeenMillis = defaults.double(forKey: "lastSeenNotificationMillis")
            var newestSeen = lastSeenMillis
            
            print("[\(TAG)] Notifications count = \(notifications.count)")
            
            for (index, notification) in notifications.enumerated() {
                let token = notification["token"] as? String ?? "\(index)"
                let isMarket = notification["is_market"] as? String ?? "0"
                let isRead = notification["is_read"] as? String ?? "1"
                let createdAt = notification["created_at"] as? String ?? ""
                let title = notification["title"] as? String ?? "Notification"
                let body = notification["body"] as? String ?? title
                
                let createdMillis = parseTime(createdAt)
                
                let shouldShow = isMarket == "1" && isRead == "0" && createdMillis > lastSeenMillis
                
                print("[\(TAG)] Notif[\(index)] market=\(isMarket), read=\(isRead), created=\(createdAt), millis=\(createdMillis), show=\(shouldShow)")
                
                if shouldShow {
                    let notificationId = token.hashValue
                    print("[\(TAG)] SHOWING notification id=\(notificationId)")
                    showMobileNotification(title: title, body: body, notificationId: notificationId, token: token, createdAt: createdAt)
                    
                    if createdMillis > newestSeen {
                        newestSeen = createdMillis
                    }
                }
            }
            
            if newestSeen > lastSeenMillis {
                defaults.set(newestSeen, forKey: "lastSeenNotificationMillis")
                print("[\(TAG)] Updated lastSeenMillis → \(newestSeen)")
            }
            
        } catch {
            print("[\(TAG)] parseAndShowNotifications ERROR: \(error)")
        }
    }
    
    // MARK: - Show Notification
    
    private func showMobileNotification(title: String, body: String, notificationId: Int, token: String, createdAt: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = MARKET_CHANNEL_ID
        
        // Add user info for handling tap
        content.userInfo = [
            "notification_payload_title": title,
            "notification_payload_body": body,
            "notification_token": token,
            "notification_created_at": createdAt
        ]
        
        // Create request with unique identifier
        let request = UNNotificationRequest(
            identifier: "\(notificationId)",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        // Add the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[\(self.TAG)] Notification POST FAILED: \(error)")
            } else {
                print("[\(self.TAG)] Notification POSTED → id=\(notificationId)")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func parseTime(_ timeString: String) -> Double {
        if let date = dateFormatter.date(from: timeString) {
            return date.timeIntervalSince1970 * 1000
        }
        print("[\(TAG)] Time parse failed: \(timeString)")
        return 0
    }
}

// MARK: - App Lifecycle Integration

extension NotificationService {
    
    /// Call this when app enters foreground
    func applicationWillEnterForeground() {
        print("[\(TAG)] App entering FOREGROUND → resume polling")
        startForegroundPolling()
    }
    
    /// Call this when app enters background
    func applicationDidEnterBackground() {
        print("[\(TAG)] App entering BACKGROUND → schedule background task")
        pollingTimer?.invalidate()
        pollingTimer = nil
        
        if #available(iOS 13.0, *) {
            scheduleBackgroundTask()
        }
    }
}
