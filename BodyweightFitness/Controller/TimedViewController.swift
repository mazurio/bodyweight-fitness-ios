import UIKit
import AVFoundation

class TimedViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet var timerMinutesButton: UIButton!
    @IBOutlet var timerSecondsButton: UIButton!
    
    @IBOutlet var timerPlayButton: UIButton!
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    var rootViewController: WorkoutViewController? = nil
    var current: Exercise = RoutineStream.sharedInstance.routine.getFirstExercise()
    
    var audioPlayer: AVAudioPlayer?
    var timePickerController: TimePickerController?
    var timer = NSTimer()
    var isPlaying = false
    
    var seconds = 60
    var defaultSeconds = 60
    var loggedSeconds = 0
    
    init() {
        super.init(nibName: "TimedView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeExercise(currentExercise: Exercise) {
        self.current = currentExercise
        
        let savedSeconds = PersistenceManager.getTimer(currentExercise.exerciseId)
        
        self.loggedSeconds = 0
        self.defaultSeconds = savedSeconds
        
        self.restartTimer(savedSeconds)
        
        if let _ = self.current.previous {
            self.previousButton.hidden = false
        } else {
            self.previousButton.hidden = true
        }
        
        if let _ = self.current.next {
            self.nextButton.hidden = false
        } else {
            self.nextButton.hidden = true
        }
    }
    
    func updateLabel() {
        let (_, m, s) = secondsToHoursMinutesSeconds(seconds)
        
        timerMinutesButton.setTitle(printTimerValue(m), forState: UIControlState.Normal)
        timerSecondsButton.setTitle(printTimerValue(s), forState: UIControlState.Normal)
    }
    
    func printTimerValue(value: Int) -> String {
        if(value > 9) {
            return String(value)
        } else {
            return "0" + String(value)
        }
    }
  
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func stopTimer() {
        isPlaying = false
        
        timerPlayButton.setImage(
            UIImage(named: "play") as UIImage?,
            forState: UIControlState.Normal)
        
        timer.invalidate()
        
        self.logSeconds()
    }
    
    func startTimer() {
        isPlaying = true
        
        timerPlayButton.setImage(
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
    func setTimeAction() {
        if let seconds = self.timePickerController?.getTotalSeconds() {
            self.defaultSeconds = seconds
            self.restartTimer(seconds)

            PersistenceManager.storeTimer(current.exerciseId, seconds: self.defaultSeconds)
        }
    }
    
    func logSeconds() {
        if let current = self.rootViewController?.current {
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

                    RoutineStream.sharedInstance.setRepository()
                }
            }
            
        }
        
        loggedSeconds = 0
    }
    
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
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false, withOptions:
                AVAudioSessionSetActiveOptions.NotifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession errors.")
        }
    }
    
    func showNotification(seconds: Int) {
        let notification = CWStatusBarNotification()
        
        notification.notificationLabelFont = UIFont.boldSystemFontOfSize(17)
        notification.notificationLabelBackgroundColor = UIColor.primary()
        notification.notificationLabelTextColor = UIColor.primaryDark()
        
        notification.notificationStyle = .NavigationBarNotification
        notification.notificationAnimationInStyle = .Top
        notification.notificationAnimationOutStyle = .Top
        
        notification.displayNotificationWithMessage("Logged \(seconds) seconds", forDuration: 2.0)
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
    
    
    @IBAction func previousButtonClicked(sender: AnyObject) {
        self.rootViewController?.previousButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        self.rootViewController?.nextButtonClicked(sender)
    }
}