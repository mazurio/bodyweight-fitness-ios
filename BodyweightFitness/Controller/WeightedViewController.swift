import UIKit

class WeightedViewController: UIViewController {
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var logButton: UIButton!
    
    @IBOutlet var repsValueLabel: UILabel!
    
    // remember numberOfReps per exercise
    // set number when loading to the number of exercise
    var numberOfReps: Int = 5
    var rootViewController: RootViewController? = nil
    
    init() {
        super.init(nibName: "WeightedView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.repsValueLabel.text = String(self.numberOfReps)
    }
    
    func showNotification(set: Int, reps: Int) {
        let notification = CWStatusBarNotification()
        
        notification.notificationLabelFont = UIFont.boldSystemFontOfSize(17)
        notification.notificationLabelBackgroundColor = UIColor.primary()
        notification.notificationLabelTextColor = UIColor.primaryDark()
        
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Top
        notification.notificationAnimationOutStyle = .Top
        
        notification.displayNotificationWithMessage("Logged Set \(set), Reps \(reps)", forDuration: 2.0)
    }
    
    @IBAction func previousButtonClicked(sender: AnyObject) {
        self.rootViewController?.previousButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        self.rootViewController?.nextButtonClicked(sender)
    }
    
    @IBAction func increaseRepsClicked(sender: AnyObject) {
        if self.numberOfReps < 25 {
            self.numberOfReps += 1
            
            self.repsValueLabel.text = String(self.numberOfReps)
        }
    }
    
    @IBAction func decreaseRepsClicked(sender: AnyObject) {
        if self.numberOfReps > 1 {
            self.numberOfReps -= 1
            
            self.repsValueLabel.text = String(self.numberOfReps)
        }
    }
    
    @IBAction func logReps(sender: AnyObject) {
        if let current = self.rootViewController?.current {
            if (self.numberOfReps >= 1 && self.numberOfReps <= 25 && !current.isTimed()) {
                let realm = RepositoryStream.sharedInstance.getRealm()
                let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
                
                if let repositoryExercise = repositoryRoutine.exercises.filter({
                    $0.exerciseId == current.exerciseId
                }).first {
                    let sets = repositoryExercise.sets
                    
                    try! realm.write {
                        if (sets.count == 1 && sets[0].reps == 0) {
                            sets[0].reps = self.numberOfReps
                            
                            showNotification(1, reps: self.numberOfReps)
                        } else if (sets.count >= 1 && sets.count < 9) {
                            let repositorySet = RepositorySet()
                            
                            repositorySet.exercise = repositoryExercise
                            repositorySet.isTimed = false
                            repositorySet.reps = self.numberOfReps
                            
                            sets.append(repositorySet)
                            
                            repositoryRoutine.lastUpdatedTime = NSDate()
                            
                            showNotification(sets.count, reps: self.numberOfReps)
                        }
                        
                        realm.add(repositoryRoutine, update: true)
                    }
                }
            }
        }
    }
}