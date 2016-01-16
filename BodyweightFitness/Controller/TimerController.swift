import UIKit
import AVFoundation

class TimerController: UIViewController, AVAudioPlayerDelegate {
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
    var actionButtonDelegate: UIActionSheetDelegate?
    var chooseProgressionDelegate: UIActionSheetDelegate?
    
    @IBAction func onClickMenuAction(sender: AnyObject) {
        sideNavigationViewController?.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actionButtonDelegate = ActionButtonDelegate(timerController: self)
        self.chooseProgressionDelegate = ChooseProgressionDelegate(timerController: self)
        
        mainView.backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)

        setNavigationBar()
        updateLabel()
        changeExercise(RoutineStream.sharedInstance.routine.getFirstExercise())
    }
    
    internal func changeExercise(currentExercise: Exercise) {
        self.current = currentExercise
        
        setNavigationBarTitle(currentExercise.title)
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
        if let _ = current?.section?.exercises {
            let sheet = UIActionSheet(
                title: nil,
                delegate: actionButtonDelegate,
                cancelButtonTitle: "Cancel",
                destructiveButtonTitle: nil)
            
            sheet.tintColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1)
      
            sheet.addButtonWithTitle("Watch on YouTube")
            
            addChooseProgressionButton(sheet)
            
            sheet.showInView(self.view)
        }
    }
    
    func addChooseProgressionButton(sheet: UIActionSheet) {
        if(current?.section?.mode == SectionMode.Levels || current?.section?.mode == SectionMode.Pick) {
            sheet.addButtonWithTitle("Choose Progression")
        }
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
            restartTimer(self.defaultSeconds)
            
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
    
    ///
    /// Set title of the navigation bar.
    ///
    func setNavigationBarTitle(title: String) {
        navigationItem.title = title
    }
    
    func setNavigationBar() {
        //
        // Apply primary dark color to the title in navigation bar.
        //
        let titleDict: NSDictionary = [
            NSForegroundColorAttributeName: UIColor(red:0, green:0.27, blue:0.24, alpha:1)
        ]
        
        navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        navigationController!.navigationBar.translucent = true
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.setBackgroundImage(
            UIImage(),
            forBarMetrics: UIBarMetrics.Default
        )
    }
}