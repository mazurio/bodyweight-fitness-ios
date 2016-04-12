import UIKit
import Material
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var mask: CALayer?
    
    var sideNavigationViewController: SideNavigationController?
    
    var sideViewController: UIViewController = SideViewController()
    var mainViewController: UIViewController?
    var workoutLogViewController = UINavigationController(rootViewController: WorkoutLogViewController())
    var supportDeveloperViewController = UINavigationController(rootViewController: SupportDeveloperViewController())
    var settingsViewController = UINavigationController(rootViewController: SettingsViewController())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])

        UITabBar.appearance().backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        UITabBar.appearance().tintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
      
        sideNavigationViewController = SideNavigationController(
            rootViewController: mainViewController!,
            leftViewController: sideViewController
        )
        
        sideNavigationViewController?.setLeftViewWidth(260, hidden: true, animated: false)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = sideNavigationViewController!
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
}

