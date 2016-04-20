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
//        Fabric.with([Crashlytics.self])
        
        self.shouldMigrateSchemaIfNeeded()
        
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
    
    func shouldMigrateSchemaIfNeeded() {
        print("shouldMigrateSchemaIfNeeded")
        
        if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
            print("repositoryRoutineForTodayExists")
            
            let routine = RoutineStream.sharedInstance.routine
            let currentSchema = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
            
            let (shouldRemoveCurrentSchema, newSchema) = migrateSchemaIfNeeded(routine, currentSchema: currentSchema)
            
            if shouldRemoveCurrentSchema {
                print("shouldRemoveCurrentSchema")
                
                let realm = RepositoryStream.sharedInstance.getRealm()
                
                try! realm.write {
                    print("realm.write")
                    
                    realm.add(newSchema, update: false)
                    realm.delete(currentSchema)
                }
            } else {
                print("shouldNotRemoveCurrentSchema")
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

