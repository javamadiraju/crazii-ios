import UIKit
import Flutter
import UserNotifications
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let TAG = "AppDelegate"
    private let CHANNEL = "notification_channel"
    private var methodChannel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Setup Flutter method channel for notification handling
        if let controller = window?.rootViewController as? FlutterViewController {
            methodChannel = FlutterMethodChannel(
                name: CHANNEL,
                binaryMessenger: controller.binaryMessenger
            )
        }
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Start the notification polling service
        NotificationService.shared.startService()
        
        // Register background tasks (iOS 13+)
        if #available(iOS 13.0, *) {
            registerBackgroundTasks()
        }
        
        // Handle notification if app was launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            handleNotificationPayload(notification)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Background Tasks Registration (iOS 13+)
    
    @available(iOS 13.0, *)
    private func registerBackgroundTasks() {
        // Register the background app refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: NotificationService.backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        print("[\(TAG)] Background tasks registered")
    }
    
    @available(iOS 13.0, *)
    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("[\(TAG)] Handling background app refresh")
        
        // Schedule the next background task
        NotificationService.shared.scheduleBackgroundTask()
        
        // Set expiration handler
        task.expirationHandler = {
            print("[\(self.TAG)] Background task expired")
            task.setTaskCompleted(success: false)
        }
        
        // Check for notifications
        NotificationService.shared.checkNotificationsNow { success in
            print("[\(self.TAG)] Background task completed: \(success)")
            task.setTaskCompleted(success: success)
        }
    }
    
    // MARK: - App Lifecycle
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        super.applicationWillEnterForeground(application)
        print("[\(TAG)] App will enter foreground")
        NotificationService.shared.applicationWillEnterForeground()
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
        print("[\(TAG)] App did enter background")
        NotificationService.shared.applicationDidEnterBackground()
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        super.applicationWillTerminate(application)
        print("[\(TAG)] App will terminate")
        NotificationService.shared.stopService()
    }
    
    // MARK: - Notification Handling
    
    private func handleNotificationPayload(_ userInfo: [String: Any]) {
        guard let title = userInfo["notification_payload_title"] as? String else {
            return
        }
        
        let body = userInfo["notification_payload_body"] as? String ?? ""
        let token = userInfo["notification_token"] as? String ?? ""
        let createdAt = userInfo["notification_created_at"] as? String ?? ""
        
        print("[\(TAG)] Notification clicked: \(title) | \(body)")
        
        // Send to Flutter
        methodChannel?.invokeMethod("notificationClick", arguments: [
            "title": title,
            "body": body,
            "token": token,
            "created_at": createdAt
        ])
    }
    
    // MARK: - Remote Notifications
    
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("[\(TAG)] Received remote notification")
        
        // Check for new notifications
        NotificationService.shared.checkNotificationsNow { success in
            completionHandler(success ? .newData : .noData)
        }
    }
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[\(TAG)] Device token: \(token)")
    }
    
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[\(TAG)] Failed to register for remote notifications: \(error)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate {
    
    // Handle notification when app is in foreground
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("[\(TAG)] Notification received in foreground")
        
        // Show the notification even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // Handle notification tap
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[\(TAG)] Notification tapped: \(userInfo)")
        
        // Handle the notification payload
        if let payload = userInfo as? [String: Any] {
            handleNotificationPayload(payload)
        }
        
        completionHandler()
    }
}
