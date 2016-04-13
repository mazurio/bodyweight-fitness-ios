import UIKit
import Material
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var sideNavigationViewController: SideNavigationController?
    
    var sideViewController: UIViewController = SideViewController()
    var mainViewController: UIViewController?
    var workoutLogViewController = UINavigationController(rootViewController: WorkoutLogViewController())
    var supportDeveloperViewController = UINavigationController(rootViewController: SupportDeveloperViewController())
    var settingsViewController = UINavigationController(rootViewController: SettingsViewController())

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
      
        self.sideNavigationViewController = SideNavigationController(
            rootViewController: self.mainViewController!,
            leftViewController: self.sideViewController
        )
        
        self.sideNavigationViewController?.setLeftViewWidth(260, hidden: true, animated: false)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
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

