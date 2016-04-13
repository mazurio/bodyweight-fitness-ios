import UIKit
import AVFoundation
import SwiftCharts

class RootViewController: UIViewController, AVAudioPlayerDelegate {
//    @IBOutlet var exerciseTitle: UILabel!
//    @IBOutlet var sectionTitle: UILabel!
//    @IBOutlet var exerciseDescription: UILabel!
    
//    @IBOutlet var menuButton: UIBarButtonItem!
//    @IBOutlet var dashboardButton: UIBarButtonItem!
    
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var timerMinutesButton: UIButton!
    @IBOutlet var timerButton: UIButton!
    @IBOutlet var mainView: UIView!
    @IBOutlet var gifView: AnimatableImageView!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    var timePickerController: TimePickerController?
    var timer = NSTimer()
    var isPlaying = false
    var seconds = PersistenceManager.getTimer()
    var defaultSeconds = PersistenceManager.getTimer()
    var loggedSeconds = 0
    
    var current: Exercise?
    
    var audioPlayer: AVAudioPlayer?
    
    init() {
        super.init(nibName: "RootView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        let menuItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss))

        let dashboardItem = UIBarButtonItem(
            image: UIImage(named: "dashboard"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dashboard))
        
        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.rightBarButtonItem = dashboardItem
        
        mainView.backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        setNavigationBar()
        updateLabel()
        changeExercise(RoutineStream.sharedInstance.routine.getFirstExercise())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setTitle()
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setTitle()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        setTitle()
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
    
    func dashboard(sender: UIBarButtonItem) {
        let dashboard = DashboardViewController()
        dashboard.currentExercise = current
        dashboard.rootViewController = self
        
        let controller = UINavigationController(rootViewController: dashboard)
        
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func onClickLogWorkoutAction(sender: AnyObject) {
        self.stopTimer()
        
        let logWorkoutController = LogWorkoutController()
        
        logWorkoutController.parentController = self.navigationController
        logWorkoutController.setRepositoryRoutine(current!, repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
        
        logWorkoutController.modalTransitionStyle = .CoverVertical
        logWorkoutController.modalPresentationStyle = .Custom
        
        self.navigationController?.dim(.In, alpha: 0.5, speed: 0.5)
        self.navigationController?.presentViewController(logWorkoutController, animated: true, completion: nil)
    }
    
    func showNotification(seconds: Int) {
        let notification = CWStatusBarNotification()
        notification.notificationLabelFont = UIFont.systemFontOfSize(17)
        notification.notificationLabelBackgroundColor = UIColor.primary()
        notification.notificationLabelTextColor = UIColor.primaryDark()
        
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Top
        notification.notificationAnimationOutStyle = .Top
        
        notification.displayNotificationWithMessage("Logged \(seconds) seconds", forDuration: 2.0)
    }
    
    func setTitle() {
        let navigationBarSize = self.navigationController?.navigationBar.frame.size
        let titleView = self.navigationItem.titleView
        var titleViewFrame = titleView?.frame
        titleViewFrame?.size = navigationBarSize!
        self.navigationItem.titleView?.frame = titleViewFrame!
        
        titleView?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin]
        titleView?.autoresizesSubviews = true
    }
    
    internal func changeExercise(currentExercise: Exercise) {
        self.loggedSeconds = 0
        
        self.current = currentExercise
        
//        self.exerciseTitle.text = currentExercise.title
//        self.exerciseDescription.text = currentExercise.desc
//        self.sectionTitle.text = currentExercise.section?.title
        
        restartTimer(defaultSeconds)
        setGifImage(currentExercise.id)
        
        if (currentExercise.section?.mode == SectionMode.All) {
            if let image = UIImage(named: "plus") {
                actionButton.setImage(image, forState: .Normal)
            }
        } else {
            if let image = UIImage(named: "progression") {
                actionButton.setImage(image, forState: .Normal)
            }
        }
        
        if let _ = self.current?.previous {
            previousButton.hidden = false
        } else {
            previousButton.hidden = true
        }
        
        if let _ = self.current?.next {
            nextButton.hidden = false
        } else {
            nextButton.hidden = true
        }
    }
    
    func setGifImage(id: String) {
        let imageData = NSData(contentsOfURL: NSBundle
            .mainBundle()
            .URLForResource(id, withExtension: "gif")!)
        
        gifView.animateWithImageData(imageData!)
    }
    
    @IBAction func actionButtonClicked(sender: AnyObject) {
        guard let button = sender as? UIView else {
            return
        }
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.popoverPresentationController
        alertController.modalPresentationStyle = .Popover
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = button;
            presenter.sourceRect = button.bounds;
        }
        
        // ... Cancel Action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        // ... Watch on YouTube Action
        alertController.addAction(
            UIAlertAction(title: "Watch on YouTube", style: .Default) { (action) in
                /// ... Watch on YouTube
                if let youTubeId = self.current?.youTubeId {
                    if let requestUrl = NSURL(string: "https://www.youtube.com/watch?v=" + youTubeId) {
                        UIApplication.sharedApplication().openURL(requestUrl)
                    }
                }
            }
        )
        
        // ... Today's Workout Action
        alertController.addAction(UIAlertAction(title: "Today's Workout", style: .Default) { (action) in
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            
            self.navigationItem.backBarButtonItem = backItem
            
            let progressViewController = ProgressViewController()
            
            progressViewController.setRoutine(NSDate(), repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
            
            self.showViewController(progressViewController, sender: nil)
            })
        
        // ... Choose Progression Action
        if let currentSection = current?.section {
            if (currentSection.mode == .Levels || currentSection.mode == .Pick) {
                // ... Choose Progression
                alertController.addAction(
                    UIAlertAction(title: "Choose Progression", style: .Default) { (action) in
                        if let exercises = self.current?.section?.exercises {
                            let alertController = UIAlertController(
                                title: "Choose Progression",
                                message: nil,
                                preferredStyle: .ActionSheet)
                            
                            alertController.modalPresentationStyle = .Popover
                            
                            if let presenter = alertController.popoverPresentationController {
                                presenter.sourceView = button;
                                presenter.sourceRect = button.bounds;
                            }
                            
                            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                            
                            for anyExercise in exercises {
                                if let exercise = anyExercise as? Exercise {
                                    var title = ""
                                    
                                    if(exercise.section?.mode == SectionMode.Levels) {
                                        title = "\(exercise.level): \(exercise.title)"
                                    } else {
                                        title = "\(exercise.title)"
                                    }
                                    
                                    alertController.addAction(
                                        UIAlertAction(title: title, style: .Default) { (action) in
                                            RoutineStream.sharedInstance.routine.setProgression(exercise)
                                            
                                            self.changeExercise(exercise)
                                            
                                            PersistenceManager.storeRoutine(RoutineStream.sharedInstance.routine)
                                        }
                                    )
                                }
                            }
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                )
            }
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    ///
    /// Previous exercise button.
    ///
    @IBAction func previousButtonClicked(sender: AnyObject) {
        if let previous = self.current?.previous {
            changeExercise(previous)
        }
    }
    
    ///
    /// Next exercise button.
    ///
    @IBAction func nextButtonClicked(sender: AnyObject) {
        if let next = self.current?.next {
            changeExercise(next)
        }
    }
    
    ///
    /// Callback from alert action that time has been set.
    ///
    func setTimeAction() {
        if let seconds = self.timePickerController?.getTotalSeconds() {
            self.defaultSeconds = seconds
            self.restartTimer(seconds)
            
            PersistenceManager.storeTimer(self.defaultSeconds)
        }
    }
    
    ///
    /// Timer button that opens popup picker.
    ///
    @IBAction func timerButton(sender: AnyObject) {
        stopTimer()
        
        timePickerController = TimePickerController()
        timePickerController?.setDefaultTimer(self.seconds)
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        let setTimeAlertAction = UIAlertAction(
            title: "Set Timer",
            style: UIAlertActionStyle.Default) { action -> Void in self.setTimeAction() }
        
        alertController.setValue(timePickerController, forKey: "contentViewController");
        alertController.addAction(setTimeAlertAction)
        
        self.parentViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func increaseButton(sender: AnyObject) {
        seconds += 5
        updateLabel()
    }
    
    @IBAction func playButton(sender: AnyObject) {
        if(isPlaying) {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    @IBAction func restartButton(sender: AnyObject) {
        restartTimer(defaultSeconds)
    }
    
    func stopTimer() {
        isPlaying = false
        
        playButton.setImage(
            UIImage(named: "play") as UIImage?,
            forState: UIControlState.Normal)
        
        timer.invalidate()
        
        self.logSeconds()
    }
    
    func startTimer() {
        isPlaying = true
        
        playButton.setImage(
            UIImage(named: "pause") as UIImage?,
            forState: UIControlState.Normal)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func restartTimer(seconds: Int) {
        stopTimer()
        
        self.seconds = seconds
        self.logSeconds()
        
        updateLabel()
    }
    
    func updateTimer() {
        seconds -= 1
        loggedSeconds += 1
        
        if(seconds <= 0) {
            restartTimer(defaultSeconds)
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if(defaults.objectForKey("playAudioWhenTimerStops") != nil) {
                let playAudioWhenTimerStops = defaults.boolForKey("playAudioWhenTimerStops")
                if(playAudioWhenTimerStops) {
                    audioPlayerStart()
                }
            } else {
                audioPlayerStart()
            }
        }
        
        updateLabel()
    }
    
    ///
    /// Play Audio.
    ///
    func audioPlayerStart() {
        let alertSound = NSURL(fileURLWithPath: NSBundle
            .mainBundle()
            .pathForResource("finished", ofType: "mp3")!)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound, fileTypeHint: nil)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("AVAudioSession errors.")
        }
    }
    
    func logSeconds() {
        if let current = current {
            if (loggedSeconds > 1 && current.isTimed()) {
                let realm = RepositoryStream.sharedInstance.getRealm()
                let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
                
                if let repositoryExercise = repositoryRoutine.exercises.filter({
                    $0.exerciseId == current.exerciseId
                }).first {
                    let sets = repositoryExercise.sets
                    
                    try! realm.write {
                        if (sets.count == 1 && sets[0].seconds == 0) {
                            sets[0].seconds = loggedSeconds
                            
                            showNotification(loggedSeconds)
                        } else if (sets.count >= 1 && sets.count < 9) {
                            let repositorySet = RepositorySet()
                            
                            repositorySet.exercise = repositoryExercise
                            repositorySet.isTimed = true
                            repositorySet.seconds = loggedSeconds
                            
                            sets.append(repositorySet)
                            
                            repositoryRoutine.lastUpdatedTime = NSDate()
                            
                            showNotification(loggedSeconds)
                        }
                        
                        realm.add(repositoryRoutine, update: true)
                    }
                }
            }
            
        }
        
        loggedSeconds = 0
    }
    
    ///
    /// Notify others that audio has finished playing so they can resume (e.g. Music Player like iTunes or Spotify).
    ///
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions:
                AVAudioSessionSetActiveOptions.NotifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession errors.")
        }
    }
    
    ///
    /// Print label to the screen.
    ///
    func updateLabel() {
        let (_, m, s) = secondsToHoursMinutesSeconds(seconds)
        
        timerMinutesButton.setTitle(printTimerValue(m), forState: UIControlState.Normal)
        timerButton.setTitle(printTimerValue(s), forState: UIControlState.Normal)
    }
    
    ///
    /// Allows to format timer value e.g. 1 as 01
    ///
    func printTimerValue(value: Int) -> String {
        if(value > 9) {
            return String(value)
        } else {
            return "0" + String(value)
        }
    }
    
    ///
    /// Converts value in seconds to hours, minutes and seconds.
    ///
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}