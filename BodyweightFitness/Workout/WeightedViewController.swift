import UIKit

class WeightedViewController: UIViewController {
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var logButton: UIButton!
    
    @IBOutlet var sets: UILabel!
    @IBOutlet var reps: UIButton!
    
    var numberOfReps: Int = 5
    var rootViewController: WorkoutViewController? = nil
    var current: Exercise = RoutineStream.sharedInstance.routine.getFirstExercise()
    
    init() {
        super.init(nibName: "WeightedView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLabels()

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribe(onNext: { (it) in
            self.sets.text = self.printSets()
        })
    }
    
    func changeExercise(_ currentExercise: Exercise) {
        self.current = currentExercise
        
        self.numberOfReps = PersistenceManager.getNumberOfReps(currentExercise.exerciseId)
        
        self.updateLabels()
        
        if let _ = self.current.previous {
            self.previousButton.isHidden = false
        } else {
            self.previousButton.isHidden = true
        }
        
        if let _ = self.current.next {
            self.nextButton.isHidden = false
        } else {
            self.nextButton.isHidden = true
        }
    }
    
    func updateLabels() {
        PersistenceManager.storeNumberOfReps(current.exerciseId, numberOfReps: self.numberOfReps)
        
        self.sets.text = self.printSets()
        self.reps.setTitle(printValue(self.numberOfReps), for: UIControlState())
    }
    
    func printValue(_ value: Int) -> String {
        if(value > 9) {
            return String(value)
        } else {
            return "0" + String(value)
        }
    }
    
    func showRestTimer() {
        self.rootViewController?.restTimerShouldStart()
    }
    
    func showNotification(_ set: Int, reps: Int) {
        let notification = CWStatusBarNotification()
        
        notification.notificationLabelFont = UIFont.boldSystemFont(ofSize: 17)
        notification.notificationLabelBackgroundColor = UIColor.primary()
        notification.notificationLabelTextColor = UIColor.primaryDark()
        
        notification.notificationStyle = .navigationBarNotification
        notification.notificationAnimationInStyle = .top
        notification.notificationAnimationOutStyle = .top
        
        notification.displayNotificationWithMessage("Logged Set \(set) - \(reps) reps", forDuration: 2.0)
        
        self.updateLabels()
    }

    func printSets() -> String {
        var numberOfSets = 0
        var isEmpty = false

        let asString = NSMutableString()

        if let current = self.rootViewController?.current {
            if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
                let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()

                if let repositoryExercise = repositoryRoutine.exercises.filter({
                    $0.exerciseId == current.exerciseId
                }).first {
                    for set in repositoryExercise.sets {
                        if (repositoryExercise.sets.count == 1 && set.reps == 0) {
                            isEmpty = true
                        }

                        asString.append("\(set.reps)-")

                        numberOfSets += 1
                    }

                    asString.append("X")
                }
            } else {
                isEmpty = true
            }
        }

        if (isEmpty) {
            return "First Set"
        } else if (numberOfSets >= 9) {
            return "Move on"
        } else if (numberOfSets >= 5) {
            return "Set \(numberOfSets + 1)"
        }

        return asString as String
    }
    
    @IBAction func previousButtonClicked(_ sender: AnyObject) {
        self.rootViewController?.previousButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(_ sender: AnyObject) {
        self.rootViewController?.nextButtonClicked(sender)
    }
    
    @IBAction func increaseRepsClicked(_ sender: AnyObject) {
        if self.numberOfReps < 25 {
            self.numberOfReps += 1
            
            self.updateLabels()
        }
    }
    
    @IBAction func decreaseRepsClicked(_ sender: AnyObject) {
        if self.numberOfReps > 1 {
            self.numberOfReps -= 1
            
            self.updateLabels()
        }
    }
    
    @IBAction func logReps(_ sender: AnyObject) {
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
                            
                            self.showNotification(1, reps: self.numberOfReps)
                            self.showRestTimer()
                        } else if (sets.count >= 1 && sets.count < 9) {
                            let repositorySet = RepositorySet()
                            
                            repositorySet.exercise = repositoryExercise
                            repositorySet.isTimed = false
                            repositorySet.reps = self.numberOfReps
                            
                            sets.append(repositorySet)
                            
                            repositoryRoutine.lastUpdatedTime = Date()
                        }
                        
                        realm.add(repositoryRoutine, update: true)
                        
                        self.showNotification(sets.count, reps: self.numberOfReps)
                        self.showRestTimer()
                    }

                    RoutineStream.sharedInstance.setRepository()
                }
            }
        }
    }
}
