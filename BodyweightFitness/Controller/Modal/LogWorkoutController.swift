import UIKit
import RealmSwift

class LogWorkoutController: UIViewController {
    var exercise: RepositoryExercise?
    var routine: RepositoryRoutine?
    
    @IBOutlet weak var addSetButton: UIButton!
    @IBOutlet weak var removeSetButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var increaseRepsButton: UIButton!
    @IBOutlet weak var decreaseRepsButton: UIButton!
    
    @IBOutlet weak var increaseWeightButton: UIButton!
    @IBOutlet weak var decreaseWeightButton: UIButton!
    
    @IBOutlet weak var setNumber: UILabel!
    @IBOutlet weak var repsNumber: UILabel!
    @IBOutlet weak var weightNumber: UILabel!
    
    @IBOutlet weak var setLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    var verticalStackView: UIStackView?
    var horizontalStackView: UIStackView?
    
    var increaseRepsTimer: Timer?
    var decreaseRepsTimer: Timer?
    var increaseWeightTimer: Timer?
    var decreaseWeightTimer: Timer?
    
    let timerInterval = 0.15
    let weightTimerInterval = 0.15
    
    var numberOfSetViews = 0
    var updateLastUpdatedTime = true
    var isActionViewShowing = false
    
    var setView: SetView?
    var set: RepositorySet?

    let realm = try! Realm()

    var parentController: UIViewController?
    
    func increaseRepsButtonDown(_ sender: AnyObject) {
        self.invalidateTimer(sender)
        
        increaseReps()
        
        increaseRepsTimer = Timer.scheduledTimer(
            timeInterval: timerInterval,
            target: self,
            selector: #selector(LogWorkoutController.increaseReps),
            userInfo: nil,
            repeats: true)
    }
    
    func decreaseRepsButtonDown(_ sender: AnyObject) {
        self.invalidateTimer(sender)
        
        decreaseReps()
        
        decreaseRepsTimer = Timer.scheduledTimer(
            timeInterval: timerInterval,
            target: self,
            selector: #selector(LogWorkoutController.decreaseReps),
            userInfo: nil,
            repeats: true)
    }
    
    func increaseWeightButtonDown(_ sender: AnyObject) {
        self.invalidateTimer(sender)
        
        increaseWeight()
        
        increaseWeightTimer = Timer.scheduledTimer(
            timeInterval: weightTimerInterval,
            target: self,
            selector: #selector(LogWorkoutController.increaseWeight),
            userInfo: nil,
            repeats: true)
    }
    
    func decreaseWeightButtonDown(_ sender: AnyObject) {
        self.invalidateTimer(sender)
        
        decreaseWeight()
        
        decreaseWeightTimer = Timer.scheduledTimer(
            timeInterval: weightTimerInterval,
            target: self,
            selector: #selector(LogWorkoutController.decreaseWeight),
            userInfo: nil,
            repeats: true)
    }
    
    func invalidateTimer(_ sender: AnyObject) {
        increaseRepsTimer?.invalidate()
        decreaseRepsTimer?.invalidate()
        
        increaseWeightTimer?.invalidate()
        decreaseWeightTimer?.invalidate()
    }
    
    init() {
        super.init(nibName: "LogWorkoutModalView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controlEvents: UIControlEvents = [
            UIControlEvents.touchUpInside,
            UIControlEvents.touchUpOutside,
            UIControlEvents.touchDragOutside,
            UIControlEvents.touchDragExit,
            UIControlEvents.touchCancel
        ]
        
        self.increaseRepsButton.addTarget(
            self,
            action: #selector(LogWorkoutController.increaseRepsButtonDown),
            for: .touchDown)
        
        self.increaseRepsButton.addTarget(
            self,
            action: #selector(LogWorkoutController.invalidateTimer),
            for: controlEvents)
        
        self.decreaseRepsButton.addTarget(
            self,
            action: #selector(LogWorkoutController.decreaseRepsButtonDown),
            for: .touchDown)
        
        self.decreaseRepsButton.addTarget(
            self,
            action: #selector(LogWorkoutController.invalidateTimer),
            for: controlEvents)
        
        self.increaseWeightButton.addTarget(
            self,
            action: #selector(LogWorkoutController.increaseWeightButtonDown),
            for: .touchDown)
        
        self.increaseWeightButton.addTarget(
            self,
            action: #selector(LogWorkoutController.invalidateTimer),
            for: controlEvents)
        
        self.decreaseWeightButton.addTarget(
            self,
            action: #selector(LogWorkoutController.decreaseWeightButtonDown),
            for: .touchDown)
        
        self.decreaseWeightButton.addTarget(
            self,
            action: #selector(LogWorkoutController.invalidateTimer),
            for: controlEvents)
        
        self.popupView.layer.borderColor = UIColor.black.cgColor
        self.popupView.layer.borderWidth = 0.25
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOpacity = 0.4
        self.popupView.layer.shadowRadius = 15
        self.popupView.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.popupView.layer.masksToBounds = false
        
        self.isActionViewShowing = false
        self.actionView?.isHidden = true
        
        self.verticalStackView = UIStackView()
        self.verticalStackView?.axis = UILayoutConstraintAxis.vertical;
        self.verticalStackView?.distribution = UIStackViewDistribution.equalSpacing;
        self.verticalStackView?.alignment = UIStackViewAlignment.center;
        self.verticalStackView?.spacing = 8;
        
        self.verticalStackView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.verticalStackView!)
        
        self.verticalStackView?.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        self.verticalStackView?.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        self.verticalStackView?.isHidden = false

        if let e = exercise {
            for set in e.sets {
                self.addSet(set)
            }
        }
    }
    
    func setRepositoryRoutine(repositoryExercise: RepositoryExercise, repositoryRoutine: RepositoryRoutine) {
        self.exercise = repositoryExercise
        self.routine = repositoryRoutine
    }
    
    func setRepositoryRoutine(_ exercise: Exercise, repositoryRoutine: RepositoryRoutine) {
        if let repositoryExercise = repositoryRoutine.exercises.filter({
            $0.exerciseId == exercise.exerciseId
        }).first {
            self.exercise = repositoryExercise
            self.routine = repositoryRoutine
        }
    }
    
    func addHorizontalStackViewIfNeeded() {
        if(numberOfSetViews == 0 || numberOfSetViews == 3 || numberOfSetViews == 6 || numberOfSetViews == 9) {
            self.horizontalStackView = UIStackView()
            self.horizontalStackView?.axis = UILayoutConstraintAxis.horizontal;
            self.horizontalStackView?.distribution = UIStackViewDistribution.equalSpacing;
            self.horizontalStackView?.alignment = UIStackViewAlignment.center;
            self.horizontalStackView?.spacing = 8;
            
            self.horizontalStackView?.translatesAutoresizingMaskIntoConstraints = false
            
            self.verticalStackView?.addArrangedSubview(self.horizontalStackView!)
        }
    }
    
    func pressed(_ setView: SetView!) {
        showActionView(setView)
    }
    
    func showActionView(_ setView: SetView) {
        self.setView = setView
        self.set = setView.repositorySet
        self.isActionViewShowing = true
        
        self.verticalStackView?.isHidden = true
        self.actionView?.isHidden = false
        
        self.addSetButton?.isHidden = true
        self.removeSetButton?.isHidden = true
        
        updateActionView()
    }
    
    func updateActionView() {
        if let set = set {
            if set.isTimed {
                if let setView = self.setView {
                    if let index = self.exercise?.sets.index(of: setView.repositorySet!) {
                        self.setNumber.text = "\(index + 1)"
                    } else {
                        self.setNumber.text = ""
                    }
                }
                
                let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)
                
                self.repsNumber.text = "\(minutes)"
                self.repsLabel.text = "Minutes"
                
                self.weightNumber.text = "\(seconds)"
                self.weightLabel.text = "Seconds"
            } else {
                if let setView = self.setView {
                    if let index = self.exercise?.sets.index(of: setView.repositorySet!) {
                        self.setNumber.text = "\(index + 1)"
                    } else {
                        self.setNumber.text = ""
                    }
                }
                
                self.repsNumber.text = "\(set.reps)"
                self.repsLabel.text = "Reps"
                
                self.weightNumber.text = "\(set.weight)"
                
                if PersistenceManager.getWeightUnit() == "lbs" {
                    self.weightLabel.text = "Weight (lbs)"
                } else {
                    self.weightLabel.text = "Weight (kg)"
                }
            }
        }
    }
    
    func hideActionView() {
        self.isActionViewShowing = false
        
        self.verticalStackView?.isHidden = false
        self.actionView?.isHidden = true
        
        self.addSetButton?.isHidden = false
        self.removeSetButton?.isHidden = false
    }
    
    func addSet(_ repositorySet: RepositorySet) {
        let setView = SetView()
        setView.repositorySet = repositorySet
        
        setView.addTarget(self, action: #selector(LogWorkoutController.pressed(_:)), for: .touchUpInside)
        setView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        setView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        self.addHorizontalStackViewIfNeeded()
        self.horizontalStackView?.addArrangedSubview(setView)
        
        setView.customizeAppearance()
        
        numberOfSetViews += 1
    }
    
    /**
     * Update only if the difference between start time and last updated time is less than
     * 120 minutes (it ignores changing the time later in the day after the workout ends
     * if we decide to update some values).
     */
    func setLastUpdatedTime() {
        if updateLastUpdatedTime {
            if let routine = self.routine {
                let elapsedTime = routine.startTime.timeIntervalSince(routine.lastUpdatedTime as Date)
                let minutes = (NSInteger(elapsedTime) % 3600) / 60;
                
                if (minutes < 120) {
                    routine.lastUpdatedTime = Date()
                }
            }
        }
    }
    
    @IBAction func onClickAddSet(_ sender: AnyObject) {
        if self.numberOfSetViews >= 9 {
            return;
        }

        try! realm.write {
            let repositorySet = RepositorySet()
            repositorySet.exercise = self.exercise!
                
            if(self.exercise?.defaultSet == "weighted") {
                repositorySet.isTimed = false
            } else {
                repositorySet.isTimed = true
            }
            
            //
            // Copy data from last set so we don't have to modify it again.
            //
            if let lastSet = self.exercise?.sets.last {
                repositorySet.reps = lastSet.reps
                repositorySet.weight = lastSet.weight
                repositorySet.seconds = lastSet.seconds
            }
            
            self.exercise?.sets.append(repositorySet)
            self.addSet(repositorySet)
            
            setLastUpdatedTime()
        }
    }
    
    @IBAction func onClickRemoveSet(_ sender: AnyObject) {
        if (numberOfSetViews == 1) {
            return;
        }
        
        try! realm.write {
            exercise?.sets.removeLast()
            
            setLastUpdatedTime()
        }
       
        self.horizontalStackView?.subviews.last!.removeFromSuperview()
        
        if self.horizontalStackView?.subviews.count == 0 {
            self.horizontalStackView?.removeFromSuperview()
            
            self.horizontalStackView = self.verticalStackView?.subviews.last as? UIStackView
        }
        
        numberOfSetViews -= 1
    }
    
    @IBAction func onClickButtonClose(_ sender: AnyObject) {
        if isActionViewShowing {
            self.hideActionView()
        } else {
            if let exercise = exercise {
                try! realm.write {
                    realm.add(exercise, update: true)
                }
            }
            
            RoutineStream.sharedInstance.setRepository()

            self.parentController?.dim(.out, alpha: 0.5, speed: 0.5)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func increaseReps() {
        try! realm.write {
            if let set = set {
                if set.isTimed {
                    if set.seconds / 60 >= 15 {
                        return;
                    }
                    
                    set.seconds += 60
                } else {
                    if set.reps >= 50 {
                        return;
                    }
                    
                    set.reps += 1
                }
                
                setView?.updateView()
                
                updateActionView()
                setLastUpdatedTime()
            }
        }
    }
    
    func decreaseReps() {
        try! realm.write {
            if let set = set {
                if set.isTimed {
                    if set.seconds >= 60 {
                        set.seconds -= 60
                    }
                } else {
                    if set.reps == 0 {
                        return;
                    }
                    
                    set.reps -= 1
                }
                
                setView?.updateView()
                
                updateActionView()
                setLastUpdatedTime()
            }
        }
    }

    func increaseWeight() {
        try! realm.write {
            if let set = set {
                if set.isTimed {
                    if set.seconds % 60 == 59 {
                        set.seconds -= 59
                    } else {
                        set.seconds += 1
                    }
                } else {
                    if set.weight >= 250 {
                        return;
                    }
                    
                    set.weight += 0.5
                }
                
                setView?.updateView()
                
                updateActionView()
                setLastUpdatedTime()
            }
        }
    }
    
    func decreaseWeight() {
        try! realm.write {
            if let set = set {
                if set.isTimed {
                    if set.seconds % 60 == 0 {
                        set.seconds += 59
                    } else {
                        set.seconds -= 1
                    }
                } else {
                    if set.weight <= 0 {
                        return;
                    }
                    
                    set.weight -= 0.5
                }
                
                setView?.updateView()
                
                updateActionView()
                setLastUpdatedTime()
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

class SetView: UIButton {
    var repositorySet: RepositorySet?
    
    let horizontalPadding: CGFloat = 14.0
    var buttonColor: UIColor?
    var topLabel: UILabel?
    var centerLabel: UILabel?
    var bottomLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customizeAppearance()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        customizeAppearance()
    }
    
    override func draw(_ rect: CGRect) {
        layer.borderColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1).cgColor
        layer.backgroundColor = UIColor.white.cgColor
        
        setTitleColor(tintColor, for: UIControlState())
        setTitleColor(UIColor.white, for: UIControlState.selected)
    }
    
    func customizeAppearance() {
        let containsEdgeInsets = !UIEdgeInsetsEqualToEdgeInsets(contentEdgeInsets, UIEdgeInsets.zero)
        
        contentEdgeInsets = containsEdgeInsets ? contentEdgeInsets : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 70 / 2.0
        layer.masksToBounds = false
        
        self.updateView()
    }
    
    func updateView() {
        self.removeAllSubviews()
        
        if let set = repositorySet {
            if set.isTimed {
                let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)
                
                if minutes == 0 {
                    self.centerLabel = UILabel(frame: CGRect.init(x: 0, y: 25, width: 70, height: 20))
                    self.centerLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                    self.centerLabel?.textAlignment = NSTextAlignment.center
                    self.centerLabel?.text = "\(seconds)s"
                    
                    self.addSubview(self.centerLabel!)
                } else if (minutes > 0 && seconds == 0) {
                    self.centerLabel = UILabel(frame: CGRect.init(x: 0, y: 25, width: 70, height: 20))
                    self.centerLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                    self.centerLabel?.textAlignment = NSTextAlignment.center
                    self.centerLabel?.text = "\(minutes)m"
                    
                    self.addSubview(self.centerLabel!)
                } else {
                    self.topLabel = UILabel(frame: CGRect.init(x: 0, y: 20, width: 70, height: 15))
                    self.topLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
                    self.topLabel?.textAlignment = NSTextAlignment.center
                    self.topLabel?.text = "\(minutes)m"
                    
                    self.bottomLabel = UILabel(frame: CGRect.init(x: 0, y: 38, width: 70, height: 15))
                    self.bottomLabel?.font = UIFont.systemFont(ofSize: 12.0)
                    self.bottomLabel?.textAlignment = NSTextAlignment.center
                    self.bottomLabel?.text = "\(seconds)s"
                    
                    self.addSubview(self.topLabel!)
                    self.addSubview(self.bottomLabel!)
                }
            } else {
                if set.weight == 0 {
                    self.centerLabel = UILabel(frame: CGRect.init(x: 0, y: 25, width: 70, height: 20))
                    self.centerLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                    self.centerLabel?.textAlignment = NSTextAlignment.center
                    self.centerLabel?.text = "\(set.reps)"
                    
                    self.addSubview(self.centerLabel!)
                } else {
                    self.topLabel = UILabel(frame: CGRect.init(x: 0, y: 20, width: 70, height: 15))
                    self.topLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
                    self.topLabel?.textAlignment = NSTextAlignment.center
                    self.topLabel?.text = "\(set.reps) x"
                    
                    self.bottomLabel = UILabel(frame: CGRect.init(x: 0, y: 38, width: 70, height: 15))
                    self.bottomLabel?.font = UIFont.systemFont(ofSize: 12.0)
                    self.bottomLabel?.textAlignment = NSTextAlignment.center
                    
                    if PersistenceManager.getWeightUnit() == "lbs" {
                        self.bottomLabel?.text = "\(set.weight) lbs"
                    } else {
                        self.bottomLabel?.text = "\(set.weight) kg"
                    }
                    
                    self.addSubview(self.topLabel!)
                    self.addSubview(self.bottomLabel!)
                }
            }
        }
    }
    
    func secondsToHoursMinutesSeconds (_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
