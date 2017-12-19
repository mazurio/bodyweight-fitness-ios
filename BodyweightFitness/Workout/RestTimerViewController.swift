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
    var timer = Timer()
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
    
    func changeExercise(_ currentExercise: Exercise) {
        self.current = currentExercise
        self.defaultSeconds = PersistenceManager.getRestTime()
        
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
    
    func updateLabel() {
        let (_, m, s) = secondsToHoursMinutesSeconds(seconds)
        
        timerMinutesButton.setTitle(printTimerValue(m), for: UIControlState())
        timerSecondsButton.setTitle(printTimerValue(s), for: UIControlState())
    }
    
    func printTimerValue(_ value: Int) -> String {
        if(value > 9) {
            return String(value)
        } else {
            return "0" + String(value)
        }
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func stopTimer() {
        isPlaying = false
        
        timer.invalidate()
    }
    
    func startTimer() {
        restartTimer(defaultSeconds)
        
        isPlaying = true
        
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    func restartTimer(_ seconds: Int) {
        stopTimer()
        
        self.seconds = seconds
        
        updateLabel()
    }
    
    func updateTimer() {
        seconds -= 1
        
        if(seconds <= 0) {
            self.rootViewController?.restTimerStopped()
            
            let defaults = Foundation.UserDefaults.standard
            if(defaults.object(forKey: "playAudioWhenTimerStops") != nil) {
                let playAudioWhenTimerStops = defaults.bool(forKey: "playAudioWhenTimerStops")
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
        let alertSound = URL(fileURLWithPath: Bundle.main
            .path(forResource: "finished", ofType: "mp3")!)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: alertSound, fileTypeHint: nil)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("AVAudioSession errors.")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false, with:
                AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession errors.")
        }
    }
    
    @IBAction func stopButtonClicked(_ sender: AnyObject) {
        self.rootViewController?.restTimerStopped()
    }
    
    @IBAction func previousButtonClicked(_ sender: AnyObject) {
        self.rootViewController?.previousButtonClicked(sender)
    }
    
    @IBAction func nextButtonClicked(_ sender: AnyObject) {
        self.rootViewController?.nextButtonClicked(sender)
    }
}
