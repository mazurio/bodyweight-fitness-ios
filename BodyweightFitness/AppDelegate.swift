import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var sideNavigationViewController: SideNavigationController?
    
    let sideViewController: UIViewController =
        SideViewController()
    
    let rootViewController: UINavigationController =
        UINavigationController(rootViewController: RootViewController())
    
    let workoutLogViewController =
        UINavigationController(rootViewController: WorkoutLogViewController())
    
    let supportDeveloperViewController =
        UINavigationController(rootViewController: SupportDeveloperViewController())
    
    let settingsViewController =
        UINavigationController(rootViewController: SettingsViewController())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        self.sideNavigationViewController = SideNavigationController(
            rootViewController: self.rootViewController,
            leftViewController: self.sideViewController
        )

        self.sideNavigationViewController?.setLeftViewWidth(260, hidden: true, animated: false)

        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = UIColor.primaryDark()
        self.window?.backgroundColor = UIColor.primary()
        self.window?.rootViewController = self.sideNavigationViewController!
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
}

