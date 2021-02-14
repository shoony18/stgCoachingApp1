//
//  AppDelegate.swift
//  coachingApp1
//
//  Created by 刈田修平 on 2021/01/24.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseAuth
import AVFoundation
import AVKit
import Messages
import UserNotifications
import StoreKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, SKPaymentTransactionObserver, UNUserNotificationCenterDelegate, MessagingDelegate{

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var firstLogin:String?

    
        override init() {
            FirebaseApp.configure()

        }

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            if #available(iOS 10.0, *) {
              // For iOS 10 display notification (sent via APNS)
              UNUserNotificationCenter.current().delegate = self

              let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
              UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            } else {
              let settings: UIUserNotificationSettings =
              UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
              application.registerUserNotificationSettings(settings)
            }

            application.registerForRemoteNotifications()
            Messaging.messaging().delegate = self
            Messaging.messaging().isAutoInitEnabled = true
            

            if Auth.auth().currentUser == nil {
                
//                self.window = UIWindow(frame: UIScreen.main.bounds)
//                //　Storyboardを指定
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                // Viewcontrollerを指定
//                let initialViewController = storyboard.instantiateViewController(withIdentifier:"loginView")
//                print("loginView")
//                // rootViewControllerに入れる
//                self.window?.rootViewController = initialViewController
//                // 表示
//                self.window?.makeKeyAndVisible()
            }else{
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {setting in
                    if setting.authorizationStatus == .authorized {
                        print("許可")
                    }
                    else {
                        print("未許可")
                    }
                })
                
//                self.window = UIWindow(frame: UIScreen.main.bounds)
//                //　Storyboardを指定
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                // Viewcontrollerを指定
//                let initialViewController = storyboard.instantiateViewController(withIdentifier:"mainView") as? UITabBarController
//                print("mainView")
//
//                // rootViewControllerに入れる
//                self.window?.rootViewController = initialViewController
//                // 表示
//                self.window?.makeKeyAndVisible()
            }

//            SKPaymentQueue.default().add(PurchaseManager.shared)
            SKPaymentQueue.default().add(self)
            
            return true
       
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      print("APNs token retrieved: \(deviceToken)")
        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print(token)

        Messaging.messaging().apnsToken = deviceToken
      // With swizzling disabled you must set the APNs token here.
      // Messaging.messaging().apnsToken = deviceToken
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                print("Transaction Failed \(transaction)")
            case .purchased, .restored:
                queue.finishTransaction(transaction)
                print("Transaction purchased or restored: \(transaction)")
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            }
        }
    }

}


//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//
//        print(userInfo)
//
//        completionHandler([.alert])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        if let messageID = userInfo["gcm.message_id"] {
//            print("Message ID: \(messageID)")
//        }
//
//        print(userInfo)
//
//        completionHandler()
//    }
//}
//extension AppDelegate : MessagingDelegate {
//  // [START refresh_token]
//  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
//    print("Firebase registration token: \(fcmToken)")
//
//    let dataDict:[String: String] = ["token": fcmToken]
//    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//  }
//}


extension UIView {

    /// 枠線の色
    @IBInspectable var borderColor: UIColor? {
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    /// 枠線のWidth
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    /// 角丸の大きさ
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

  /// 影の色
  @IBInspectable var shadowColor: UIColor? {
    get {
      return layer.shadowColor.map { UIColor(cgColor: $0) }
    }
    set {
      layer.shadowColor = newValue?.cgColor
      layer.masksToBounds = false
    }
  }

  /// 影の透明度
  @IBInspectable var shadowAlpha: Float {
    get {
      return layer.shadowOpacity
    }
    set {
      layer.shadowOpacity = newValue
    }
  }

  /// 影のオフセット
  @IBInspectable var shadowOffset: CGSize {
    get {
     return layer.shadowOffset
    }
    set {
      layer.shadowOffset = newValue
    }
  }

  /// 影のぼかし量
  @IBInspectable var shadowRadius: CGFloat {
    get {
     return layer.shadowRadius
    }
    set {
      layer.shadowRadius = newValue
    }
  }

}

