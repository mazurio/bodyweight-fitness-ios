import UIKit
import AVFoundation

class WorkoutViewController: UIViewController {
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var topView: UIView!

    @IBOutlet var mainView: UIView!
    @IBOutlet var videoView: UIView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    @IBOutlet weak var middleViewHeightConstraint: NSLayoutConstraint!
    
    let timedViewController: TimedViewController = TimedViewController()
    let weightedViewController: WeightedViewController = WeightedViewController()
    
    var current: Exercise = RoutineStream.sharedInstance.routine.getFirstExercise()
    
    init() {
        super.init(nibName: "WorkoutView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timedViewController.rootViewController = self
        self.weightedViewController.rootViewController = self
        self.timedViewController.view.frame = self.topView.frame
        self.timedViewController.willMoveToParentViewController(self)
        self.addChildViewController(self.timedViewController)
        self.topView.addSubview(self.timedViewController.view)
        self.timedViewController.didMoveToParentViewController(self)
        self.weightedViewController.view.frame = self.topView.frame
        self.weightedViewController.willMoveToParentViewController(self)
        self.addChildViewController(self.weightedViewController)
        self.topView.addSubview(self.weightedViewController.view)
        self.weightedViewController.didMoveToParentViewController(self)
        
        self.setNavigationBar()
        self.timedViewController.updateLabel()
        
        let rate = RateMyApp.sharedInstance
        rate.appID = "1018863605"
        rate.trackAppUsage()
        
        _ = RoutineStream.sharedInstance.routineObservable().subscribe(onNext: {
            self.current = $0.getFirstExercise()
            self.changeExercise(self.current)
        })

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "dashboard"),
                landscapeImagePhone: nil,
                style: .Plain,
                target: self,
                action: #selector(dashboard))
        
        self.setTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.changeExercise(current, updateTitle: false)
    }
    
    func setTitle() {
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))

        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.font = UIFont.systemFontOfSize(16)
        titleLabel.text = self.current.title
        titleLabel.sizeToFit()

        let subtitleLabel = UILabel(frame: CGRectMake(0, 20, 0, 0))

        subtitleLabel.backgroundColor = UIColor.clearColor()
        subtitleLabel.textColor = UIColor.primaryDark()
        subtitleLabel.font = UIFont.systemFontOfSize(13)
        subtitleLabel.text = self.current.section!.title + ", " + self.current.desc
        subtitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRectMake(0, 0, max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), 30))

        if titleLabel.frame.width >= subtitleLabel.frame.width {
            var adjustment = subtitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subtitleLabel.frame.width/2)
            subtitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }

        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        self.navigationItem.titleView = titleView
    }
    
    func dashboard(sender: UIBarButtonItem) {
        let dashboard = DashboardViewController()
        dashboard.currentExercise = current
        dashboard.rootViewController = self
        
        let controller = UINavigationController(rootViewController: dashboard)
        
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func onClickLogWorkoutAction(sender: AnyObject) {
        self.timedViewController.stopTimer()
        
        let logWorkoutController = LogWorkoutController()
        
        logWorkoutController.parentController = self.navigationController
        logWorkoutController.setRepositoryRoutine(
            current,
            repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
        
        logWorkoutController.modalTransitionStyle = .CoverVertical
        logWorkoutController.modalPresentationStyle = .Custom
    
        self.navigationController?.dim(.In, alpha: 0.5, speed: 0.5)
        self.navigationController?.presentViewController(logWorkoutController, animated: true, completion: nil)
    }

    internal func changeExercise(currentExercise: Exercise, updateTitle: Bool = true) {
        self.current = currentExercise
        
        self.timedViewController.changeExercise(currentExercise)
        self.weightedViewController.changeExercise(currentExercise)
        
        self.setVideo(currentExercise.videoId)
        
        if (currentExercise.section?.mode == SectionMode.All) {
            if let image = UIImage(named: "plus") {
                actionButton.setImage(image, forState: .Normal)
            }
        } else {
            if let image = UIImage(named: "progression") {
                actionButton.setImage(image, forState: .Normal)
            }
        }
        
        if current.isTimed() {
            self.timedViewController.view.hidden = false
            self.weightedViewController.view.hidden = true
        } else {
            self.timedViewController.view.hidden = true
            self.weightedViewController.view.hidden = false
        }

        if (updateTitle) {
            self.setTitle()
        }
    }
    
    func setVideo(videoId: String) {
        if !videoId.isEmpty {
            if let player = self.player {
                player.pause()
                self.player = nil
                
            }
            if let layer = self.playerLayer {
                layer.removeFromSuperlayer()
                self.playerLayer = nil
            }
            
            self.videoView.layer.sublayers?.removeAll()
            
            let path = NSBundle.mainBundle().pathForResource(videoId, ofType: "mp4")
            
            player = AVPlayer(URL: NSURL(fileURLWithPath: path!))
            player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.bounds
            
            self.videoView.layer.insertSublayer(playerLayer, atIndex: 0)
            
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(WorkoutViewController.playerItemDidReachEnd),
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: player!.currentItem)
            
            player!.seekToTime(kCMTimeZero)
            player!.play()
        } else {
            if let player = self.player {
                player.pause()
                self.player = nil
                
            }
            if let layer = self.playerLayer {
                layer.removeFromSuperlayer()
                self.playerLayer = nil
            }
            
            self.videoView.layer.sublayers?.removeAll()
        }
    }
    
    func playerItemDidReachEnd() {
        player!.seekToTime(kCMTimeZero)
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
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Watch Full Video", style: .Default) { (action) in
  
                if let requestUrl = NSURL(string: "https://www.youtube.com/watch?v=" + self.current.youTubeId) {
                    UIApplication.sharedApplication().openURL(requestUrl)
                }
            
        })
        
        alertController.addAction(UIAlertAction(title: "Today's Workout", style: .Default) { (action) in
            let backItem = UIBarButtonItem()
            backItem.title = "Back"

            self.tabBarController?.navigationItem.backBarButtonItem = backItem
            
            let progressViewController = ProgressViewController()
            
            progressViewController.setRoutine(NSDate(), repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
            
            self.showViewController(progressViewController, sender: nil)
        })
        
        if let currentSection = current.section {
            if (currentSection.mode == .Levels || currentSection.mode == .Pick) {
                // ... Choose Progression
                alertController.addAction(
                    UIAlertAction(title: "Choose Progression", style: .Default) { (action) in
                        if let exercises = self.current.section?.exercises {
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

    @IBAction func previousButtonClicked(sender: AnyObject) {
        if let previous = self.current.previous {
            changeExercise(previous)
        }
    }
 
    @IBAction func nextButtonClicked(sender: AnyObject) {
        if let next = self.current.next {
            changeExercise(next)
        }
    }
  }
