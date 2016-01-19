import UIKit
import MaterialKit
import CoreData
//import Fabric
//import Crashlytics

import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var mainViewController: UIViewController?
    var calendarViewController: UIViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        Fabric.with([Crashlytics()])
        
        UITabBar.appearance().backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        UITabBar.appearance().tintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sideViewController = storyboard.instantiateViewControllerWithIdentifier("SideViewController") as! SideViewController
        
        mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
        calendarViewController = storyboard.instantiateViewControllerWithIdentifier("CalendarNavigationController")

        let sideNavigationViewController = SideNavigationViewController(
            mainViewController: mainViewController!,
            sideViewController: sideViewController
        )
        
        sideNavigationViewController.setSideViewWidth(260, hidden: false, animated: false)
        sideNavigationViewController.toggle()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = sideNavigationViewController
        window?.makeKeyAndVisible()
        
//        testRealm()
        
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
    
//    func testRealm() {
//        let routine = RoutineStream.sharedInstance.routine
//        let repositoryRoutine = RepositoryStream.buildRoutine(routine)
//        
//        let realm = try! Realm()
//        try! realm.write {
//            realm.deleteAll()
//            realm.add(repositoryRoutine)
//        }
//    }
}

