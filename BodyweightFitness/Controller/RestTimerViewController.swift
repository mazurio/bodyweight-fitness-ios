import UIKit
import AVFoundation

class RestTimerViewController: UIViewController, AVAudioPlayerDelegate {
    @IBOutlet var timerMinutesButton: UIButton!
    @IBOutlet var timerSecondsButton: UIButton!
    
    @IBOutlet var timerPlayButton: UIButton!
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    var rootViewController: WorkoutViewController? = nil
    var current: Exercise = RoutineStream.sharedInstance.routine.getFirstExercise()
    
    var audioPlayer: AVAudioPlayer?
    var timer = NSTimer()
    var isPlaying = false
    
    var seconds = PersistenceManager.getRestTime()
    var defaultSeconds = PersistenceManager.getRestTime()
    
    init() {
        super.init(nibName: "RestTimerView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func changeExercise(currentExercise: Exercise) {
        self.current = currentExercise
        self.defaultSeconds = PersistenceManager.getRestTime()
        
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
        
        timer.invalidate()
    }
    
    func startTimer() {
        restartTimer(defaultSeconds)
        
        isPlaying = true
        
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
        
        updateLabel()
    }
    
    func updateTimer() {
        seconds -= 1
        
        if(seconds <= 0) {
            self.rootViewController?.restTimerStopped()
            
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
    
    @IBAction func stopButtonClicked(sender: AnyObject) {
        self.rootViewController?.restTimerStopped()
    }
    
    @IBAction func previousButtonClicked(sender: AnyObject) {
        self.rootViewController?.previousButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        self.rootViewController?.nextButtonClicked(sender)
    }
}
