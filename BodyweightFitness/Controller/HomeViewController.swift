import Foundation
import UIKit

class HomeViewController: UIViewController {
    init() {
        super.init(nibName: "HomeView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
    
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss)
        )
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "plus"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(routine)
        )
        
        self.navigationItem.title = "Bodyweight Fitness"
        
        _ = RoutineStream.sharedInstance.routineObservable().subscribe(onNext: {
            self.navigationItem.title = $0.title
        })
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
    
    func routine(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Choose Workout Routine",
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.popoverPresentationController
        alertController.modalPresentationStyle = .Popover
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Bodyweight Fitness", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("routine0")
        })
        
        alertController.addAction(UIAlertAction(title: "Molding Mobility", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("e73593f4-ee17-4b9b-912a-87fa3625f63d")
        })
        
        alertController.addAction(UIAlertAction(title: "Starting Stretching", style: .Default) { (action) in
            print("Test")
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startWorkout(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        // TODO this does not select menu item on the left
        sideNavigationController?.transitionFromRootViewController(
            (appDelegate?.workoutViewController)!,
            duration: 0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: nil,
            completion: nil)
    }
}