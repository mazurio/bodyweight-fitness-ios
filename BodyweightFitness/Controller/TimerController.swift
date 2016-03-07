import UIKit
import AVFoundation
import SwiftCharts

class TimerController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet var exerciseTitle: UILabel!
    @IBOutlet var sectionTitle: UILabel!
    @IBOutlet var exerciseDescription: UILabel!
    
    @IBOutlet var menuButton: UIBarButtonItem!
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
    
    var current: Exercise?
    
    var audioPlayer: AVAudioPlayer?
    
    @IBAction func onClickMenuAction(sender: AnyObject) {
        sideNavigationViewController?.toggle()
    }
    
    @IBAction func onClickLogWorkoutAction(sender: AnyObject) {
        let logWorkoutController = self.storyboard!.instantiateViewControllerWithIdentifier("LogWorkoutController") as! LogWorkoutController
    
        logWorkoutController.parentController = self.navigationController
        logWorkoutController.setRepositoryRoutine(current!, repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
    
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.navigationController?.modalPresentationStyle = .CurrentContext
        self.navigationController?.dim(.In, alpha: 0.5, speed: 0.5)
        self.navigationController?.presentViewController(logWorkoutController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        self.setNavigationBar()
        
        mainView.backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)

        setNavigationBar()
        updateLabel()
        changeExercise(RoutineStream.sharedInstance.routine.getFirstExercise())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
        
        if let superView = self.navigationItem.titleView?.superview {
            self.navigationItem.titleView?.frame = CGRectMake(
                0,
                0,
                superView.bounds.size.width,
                35)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if let superView = self.navigationItem.titleView?.superview {
            self.navigationItem.titleView?.frame = CGRectMake(
                0,
                0,
                superView.bounds.size.width,
                35)
        }
        
    }
    
    internal func changeExercise(currentExercise: Exercise) {
        self.current = currentExercise
        
        self.exerciseTitle.text = currentExercise.title
        self.exerciseDescription.text = currentExercise.desc
        self.sectionTitle.text = currentExercise.section?.title
        
        restartTimer(defaultSeconds)
        setGifImage(currentExercise.id)
        
//        if (currentExercise.section?.mode == SectionMode.All) {
//            if let image = UIImage(named: "plus") {
//                actionButton.setImage(image, forState: .Normal)
//            }
//        } else {
//            if let image = UIImage(named: "progression") {
//                actionButton.setImage(image, forState: .Normal)
//            }
//        }
        
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
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet)

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
            
            let progressViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProgressViewController") as! ProgressViewController
            
            progressViewController.setRoutine(NSDate(), repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
            
            self.showViewController(progressViewController, sender: nil)
            }
        )
        
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
                                            
                                            let sideViewController = self.sideNavigationViewController?.sideViewController as? SideViewController
                                            sideViewController?.notifyDataSetChanged()
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
    }
    
    func startTimer() {
        isPlaying = true
        
        playButton.setImage(
            UIImage(named: "pause") as UIImage?,
            forState: UIControlState.Normal)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: Selector("updateTimer"),
            userInfo: nil,
            repeats: true
        )
    }
    
    func restartTimer(seconds: Int) {
        stopTimer()
        self.seconds = seconds
        updateLabel()
    }
    
    func updateTimer() {
        seconds -= 1
        
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