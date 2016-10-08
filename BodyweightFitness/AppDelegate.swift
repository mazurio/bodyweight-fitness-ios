import UIKit
import CoreData
import Fabric
import Crashlytics

class TabBarController: UITabBarController {
    let homeViewController = HomeViewController()
    let workoutLogViewController = WorkoutLogViewController()
    let supportDeveloperViewController = SupportDeveloperViewController()
    let settingsViewController = SettingsViewController()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBar.tintColor = UIColor.primary()
        self.tabBar.barTintColor = UIColor.whiteColor()

        self.homeViewController.tabBarItem = UITabBarItem(
                title: "Home",
                image: UIImage(named: "tab_home"),
                selectedImage: UIImage(named: "tab_home"))

        self.workoutLogViewController.tabBarItem = UITabBarItem(
            title: "Workout Log",
            image: UIImage(named: "tab_workout_log"),
            selectedImage: UIImage(named: "tab_workout_log"))
        
        self.supportDeveloperViewController.tabBarItem = UITabBarItem(
            title: "Support Developer",
            image: UIImage(named: "tab_support_developer"),
            selectedImage: UIImage(named: "tab_support_developer"))

        self.settingsViewController.tabBarItem = UITabBarItem(
                title: "Settings",
                image: UIImage(named: "tab_settings"),
                selectedImage: UIImage(named: "tab_settings"))

        self.viewControllers = [
            self.homeViewController,
            self.workoutLogViewController,
            self.supportDeveloperViewController,
            self.settingsViewController]
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])

        self.migrateSchemaIfNeeded()
        self.setDefaultSettings()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = UIColor.primaryDark()
        self.window?.backgroundColor = UIColor.primary()
        self.window?.rootViewController = UINavigationController(rootViewController: TabBarController())
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    func setDefaultSettings() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if(defaults.objectForKey("playAudioWhenTimerStops") == nil) {
            defaults.setBool(true, forKey: "playAudioWhenTimerStops")
        }
    }
    
    func migrateSchemaIfNeeded() {
        if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
            let routine = RoutineStream.sharedInstance.routine
            let currentSchema = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
            
            let (shouldRemoveCurrentSchema, newSchema) = migrateSchemaIfNeeded(routine, currentSchema: currentSchema)
            
            if shouldRemoveCurrentSchema {
                let realm = RepositoryStream.sharedInstance.getRealm()
                
                try! realm.write {
                    realm.add(newSchema, update: false)
                    realm.delete(currentSchema)
                }
            }
        }
    }
    
    func migrateSchemaIfNeeded(routine: Routine, currentSchema: RepositoryRoutine) -> (Bool, RepositoryRoutine) {
        if (!isValidSchema(routine, currentSchema: currentSchema)) {
            let newSchema = RepositoryStream.sharedInstance.buildRoutine(routine)
            
            newSchema.startTime = currentSchema.startTime
            newSchema.lastUpdatedTime = currentSchema.lastUpdatedTime
            
            for exercise in newSchema.exercises {
                if let currentExercise = currentSchema.exercises.filter({
                    $0.exerciseId == exercise.exerciseId
                }).first {
                    exercise.sets.removeAll()
                    
                    for set in currentExercise.sets {
                        exercise.sets.append(set)
                    }
                }
            }
            
            return (true, newSchema)
        }
        
        return (false, currentSchema)
    }
    
    func isValidSchema(routine: Routine, currentSchema: RepositoryRoutine) -> Bool {
        for exercise in routine.exercises {
            if let exercise = exercise as? Exercise {
                let containsExercise = currentSchema.exercises.contains({
                    $0.exerciseId == exercise.exerciseId
                })
                
                if (!containsExercise) {
                    return false
                }
            }
        }
        
        return true
    }
}

