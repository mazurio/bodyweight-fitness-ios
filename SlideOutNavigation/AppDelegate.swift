import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
    
        let containerViewController = ContainerViewController()
    
        window!.rootViewController = containerViewController
        window!.makeKeyAndVisible()
    
        return true
    }
  
    func applicationWillResignActive(application: UIApplication) {

    }
  
    func applicationDidEnterBackground(application: UIApplication) {
    
    }
  
    func applicationWillEnterForeground(application: UIApplication) {
    
    }
  
    func applicationDidBecomeActive(application: UIApplication) {
    
    }
  
    func applicationWillTerminate(application: UIApplication) {
    
    }
}