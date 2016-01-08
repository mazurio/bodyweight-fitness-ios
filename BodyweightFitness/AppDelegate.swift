import UIKit
import MaterialKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // TODO: Choose Progression does change the exercise but linking in the Drawer is different (sometimes).
    // TODO: iPhone 4S Storyboard Updates.
    // TODO: Loading Strings from file per Flavour.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        
        UITabBar.appearance().backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        UITabBar.appearance().tintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
        let sideViewController = storyboard.instantiateViewControllerWithIdentifier("SideViewController") as! SideViewController
        
        let sideNavigationViewController = SideNavigationViewController(mainViewController: mainViewController, sideViewController: sideViewController)
        
        sideNavigationViewController.setSideViewWidth(260, hidden: false, animated: false)
        sideNavigationViewController.toggle()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = sideNavigationViewController
        window?.makeKeyAndVisible()
        
//        loadCustomStoryboardForIPhone4S()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }

    func applicationWillTerminate(application: UIApplication) {

    }
    
    // iPhone 4S
    func loadCustomStoryboardForIPhone4S() {
        let iOSDeviceScreenSize: CGSize = UIScreen.mainScreen().bounds.size
        if(iOSDeviceScreenSize.height == 480) {
            let storyboard: UIStoryboard = UIStoryboard(name: "iPhone4S", bundle: nil)
            let initial: UIViewController = storyboard.instantiateInitialViewController() as UIViewController!
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window?.rootViewController = initial
            self.window?.makeKeyAndVisible()
        }
    }
}

