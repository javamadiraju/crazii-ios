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
        // Plugins and Flutter engine must be ready before touching rootViewController / window.
        GeneratedPluginRegistrant.register(with: self)
        let launchedOk = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        setupNotificationMethodChannel()
        
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        NotificationService.shared.startService()
        
        if #available(iOS 13.0, *) {
            registerBackgroundTasks()
        }
        
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            handleNotificationPayload(notification)
        }
        
        return launchedOk
    }
    
    /// Method channel for native → Flutter notification taps (after FlutterViewController exists).
    private func setupNotificationMethodChannel() {
        if let controller = window?.rootViewController as? FlutterViewController {
            attachNotificationChannel(to: controller)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let controller = self.window?.rootViewController as? FlutterViewController else {
                print("[AppDelegate] FlutterViewController not available for notification channel")
                return
            }
            self.attachNotificationChannel(to: controller)
        }
    }
    
    private func attachNotificationChannel(to controller: FlutterViewController) {
        methodChannel = FlutterMethodChannel(
            name: CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )
    }
    
    // MARK: - Background Tasks Registration (iOS 13+)
    
    @available(iOS 13.0, *)
    private func registerBackgroundTasks() {
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
        
        NotificationService.shared.scheduleBackgroundTask()
        
        task.expirationHandler = {
            print("[\(self.TAG)] Background task expired")
            task.setTaskCompleted(success: false)
        }
        
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
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("[\(TAG)] Notification received in foreground")
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("[\(TAG)] Notification tapped: \(userInfo)")
        
        if let payload = userInfo as? [String: Any] {
            handleNotificationPayload(payload)
        }
        
        completionHandler()
    }
}
