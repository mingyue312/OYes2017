
import UIKit
//import UserNotifications
import CoreData
import Fabric
import Crashlytics
import Hyphenate
import Firebase
import Stripe
import UserNotifications

struct Platform {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /** Hyphenate configuration constants **/
    static let kHyphenateAppKey = "1500170706002947#instasolve"
    static let kHyphenatePushServiceDevelopment = "InstasolveDevCertificates"
    static let kHyphenatePushServiceProduction = "InstaSolveProductionCertificates"
    static let kSDKConfigEnableConsoleLogger = "SDKConfigEnableConsoleLogger"
    
    /** Google Analytics configuration constants **/
    static let kGaPropertyId = "updateKey"
    static let kTrackingPreferenceKey = "allowTracking"
    static let kGaDryRun = false
    static let kGaDispatchPeriod = 30
    
    var window: UIWindow?
    var mainViewController: MainViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var apnsCertName : String? = nil
        // ignore the Xcode "will never be executed" warning
        if _isDebugAssertConfiguration() {
            print("Setting test stripe key")
            Stripe.setDefaultPublishableKey("pk_test_lTfNGp2OD3CytvWX9XCPA41z")
            apnsCertName = AppDelegate.kHyphenatePushServiceDevelopment
        } else {
            print("Setting production stripe key")
            Stripe.setDefaultPublishableKey("pk_live_pmb3J5laKj7HXRw4Ro8Z8P2G")
            apnsCertName = AppDelegate.kHyphenatePushServiceProduction
        }
        
        FirebaseApp.configure()
 
        //TODO: create our own gif with our logo, need to add our gif to "copy bundle researces" under "build phase"
        //showSplashAnimation()
        
        let config = AppConfig.sharedInstance
        
        application.registerForRemoteNotifications()
        
        UINavigationBar.appearance().tintColor = UIColor.hiPrimary()
        UINavigationBar.appearance().backgroundColor = UIColor.clear
        UINavigationBar.appearance().clipsToBounds = false
        UINavigationBar.appearance().isTranslucent = true

        hyphenateApplication(application, didFinishLaunchingWithOptions: launchOptions, appKey: AppDelegate.kHyphenateAppKey, apnsCertname: apnsCertName!, otherConfig:[AppDelegate.kSDKConfigEnableConsoleLogger: NSNumber(booleanLiteral: true)])
        
        registerNotification()
        // configtype first launch is guaranteed to be int
        if (config.getConfigForType(.ConfigTypeFirstLaunch)! as! Int) < 1 {
            config.configAppFirstLaunch()
            // show alert that only available in US and Canada
            let alert = UIAlertController(title: "Service notice", message: "Currently, we offer service to Canada and the US ONLY.\nThanks for your support!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                alert.show()
            }
        }
        
        AppConfig.sharedInstance.configAppLaunch()
        return true
    }
    
    func registerNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(granted, error) in
            guard granted else {return}
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    /*
    func showSplashAnimation() {
        let background = UIView(frame: CGRect(x: 0, y: 0, width: (window?.bounds.size.width)!, height: (window?.bounds.size.height)!))
        background.backgroundColor = UIColor(red: 62/255, green: 92/255, blue: 120/255, alpha: 1)
        let splash = UIImageView(frame: CGRect(x: 0, y: 0, width: 317, height: 111))
        splash.center = (window?.center)!
        let path = Bundle.main.path(forResource: "Splash", ofType: "gif")
        splash.image = UIImage.animatedImage(withAnimatedGIFURL: URL(fileURLWithPath: path!))
        background.addSubview(splash)
        window?.addSubview(background)
        window?.bringSubview(toFront: background)
        
        background.layer.anchorPoint = CGPoint(x: -0.5, y: 0.5)
        background.frame = CGRect(x: 0, y: 0, width: (self.window?.bounds.size.width)!, height: (self.window?.bounds.size.height)!)

        UIView.animate(withDuration: TimeInterval(0.5), delay: 1.2, options: .curveEaseInOut, animations: {
            background.layer.transform = CATransform3DRotate(CATransform3DIdentity, -(CGFloat)(Double.pi / 2), 0, 1, 0);
            }) { (finished) in
            background.removeFromSuperview()
        }
    }
    */

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        EMClient.shared().applicationDidEnterBackground(application)
        //self.saveContext()
//        print("applicationdidenterbackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        EMClient.shared().applicationWillEnterForeground(application)

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // check if the user comes back from appstore when force update needed
        if AppConfig.sharedInstance.getConfigForType(.ConfigTypeAppUpdateRequired)! as! Bool {
            AppConfig.sharedInstance.displayUpdateAlertForType(.ConfigTypeAppUpdateRequired)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        self.saveContext()
        //first find the top viewcontroller to know what action to take
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            //use while loop to go down the hierarchy of viewcontrollers to find the present view controller
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
                print("\(type(of: topController))")
            }
            
            //if the current viewcontroller is a UInavigationController then find the controller at the top of the UInavigationController
            if topController is UINavigationController{
                let nVC = topController as! UINavigationController
                if let topViewController = nVC.topViewController {
                    print("\(type(of: topViewController))")
                    
                    /*If the student is in:
                        - a session we end the session and notify the tutor
                        - the connecting to tutor screen we retract the question
                        - the connected with tutor screen we notify the tutor
                    */
                    if topViewController is ChatTableViewController{
                        //Inside this if statement student is in a chat session
                        let chatVC = topViewController as! ChatTableViewController
                        chatVC.endSessionfromAppTermination()
                        print("donedismissing")
                    } else if topViewController is SummaryVC {
                        //Inside this if statement student is in connecting with tutor screen
                        let CurrentsummaryVC = topViewController as! SummaryVC
                        if CurrentsummaryVC.flag == 0{
                            CurrentsummaryVC.cancelFromAppTermination()
                        }
                    } else if topViewController is TutorConnectedVC{
                        //Inside this if statement student is on connected with tutor screen
                        //TODO: notify tutor student has left
                    }
                }

            }
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.hyphenate.messenger.Hyphenate_Messenger" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Hyphenate_Messenger", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        EMClient.shared().registerForRemoteNotifications(withDeviceToken: deviceToken) { (error) in
            if ((error) != nil) {
                print("Error!!! Failed to register remote notification - \(error?.description ?? "Remote Notification Failed")")
            }
        }
    }
}

extension AppDelegate {
    
    func hyphenateApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?, appKey: String, apnsCertname: String, otherConfig: Dictionary<String, AnyObject>)
    {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KNotification_login"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "KNotification_logout"), object: nil)
        
        let options: EMOptions = EMOptions(appkey: appKey)
        options.apnsCertName = apnsCertname
        let error:EMError? = EMClient.shared().initializeSDK(with: options)
        
        if ((error) != nil) {
            print("Failed to initialize SDK")
        }
                
        if EMClient.shared().isAutoLogin {
            proceedLogin()
        } else {
            proceedLogout()
            EMClient.shared().options.isAutoLogin = true
        }
        
        // Hyphenate
        HyphenateMessengerHelper.sharedInstance.loadConversationFromDB()
        // Fabric
        Fabric.with([Crashlytics.self])
    }
    
    // login
    func proceedLogin() {
        let uid = "+1" + EMClient.shared().currentUsername!
        AppConfig.sharedInstance.performUserSpecificConfigFor(uid)
        
        // if AppConfig.sharedInstance.profileNeedsUpdate {
        AppConfig.sharedInstance.getUserProfileAtLogin(uid)
        // }
        
        self.mainViewController = MainViewController()
        HyphenateMessengerHelper.sharedInstance.mainVC = mainViewController
        HyphenateMessengerHelper.sharedInstance.loadConversationFromDB()
        HyphenateMessengerHelper.sharedInstance.loadPushOptions()
        HyphenateMessengerHelper.sharedInstance.loadGroupFromServer()
        window?.rootViewController = UINavigationController(rootViewController: mainViewController!)
//        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
    }
    
    // logout
    func proceedLogout() {
        if EMClient.shared().isLoggedIn {
            HyphenateMessengerHelper.sharedInstance.logout()
        } else {
            proceedLoginViewController()
        }
    }
    
    func proceedLoginViewController() {
        if ((mainViewController) != nil) {
            let _ = mainViewController?.navigationController?.popToRootViewController(animated: false)
        }
        
        self.mainViewController = nil;
        
        HyphenateMessengerHelper.sharedInstance.mainVC = nil
        let loginController = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthVC")
        window?.rootViewController = loginController
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error!!! Failed to register remote notification - \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        do {
            
            let jsonData : Data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            let str : String = String(data: jsonData, encoding: String.Encoding.utf8)!
            let alert = UIAlertController(title: NSLocalizedString("apns.content", comment: ""), message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: "ok"), style: .cancel, handler: nil))
            alert.show((window?.rootViewController)!, sender: self)
            
        } catch let parseError as NSError {
            print(parseError.localizedDescription)
        }
        
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

//extension EMConversation{
//    override func setConversationId(_ convId: String){
//        self.conversationId = convId
//    }
//}

