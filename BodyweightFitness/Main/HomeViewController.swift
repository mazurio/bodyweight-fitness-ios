import UIKit
import RxSwift
import StoreKit

class HomeViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var totalWorkouts: UILabel!
    @IBOutlet weak var lastWorkout: UILabel!
    @IBOutlet weak var last7Days: UILabel!
    @IBOutlet weak var last31Days: UILabel!
    
    @IBOutlet weak var routineTitle: UILabel!
    @IBOutlet weak var routineShortDescription: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()

        self.stackView.axis = UILayoutConstraintAxis.vertical;
        self.stackView.distribution = UIStackViewDistribution.equalSpacing;
        self.stackView.alignment = UIStackViewAlignment.top;
        self.stackView.spacing = 0;

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribe(onNext: { (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
        })

        _ = RoutineStream.sharedInstance.routineObservable().subscribe(onNext: { (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
            
            self.tabBarController?.title = it.title
            self.routineTitle.text = it.title
            self.routineShortDescription.text = it.shortDescription
        })
        
        self.requestReviewIfAllowed()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tabBarController?.title = RoutineStream.sharedInstance.routine.title
        
        let storyboard = UIStoryboard(name: "WorkoutLog", bundle: Bundle.main)
        
        let p = storyboard.instantiateViewController(
            withIdentifier: "WorkoutLogViewController"
        ) as! WorkoutLogViewController
        
        p.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(p, animated: true)
    }

    func renderWorkoutProgressView() {
        let routine = RoutineStream.sharedInstance.routine

        self.stackView.removeAllSubviews()
        self.navigationItem.title = routine.title

        if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
            let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()

            for category in repositoryRoutine.categories {
                let completionRate = RepositoryCategoryHelper.getCompletionRate(category)
                let homeBarView = HomeBarView()

                homeBarView.categoryTitle.text = category.title
                homeBarView.progressView.setCompletionRate(completionRate)
                homeBarView.progressRate.text = completionRate.label

                self.stackView.addArrangedSubview(homeBarView)
            }
        } else {
            for category in routine.categories {
                if let c = category as? Category {
                    let completionRate = CompletionRate(percentage: 0, label: "0%")
                    let homeBarView = HomeBarView()

                    homeBarView.categoryTitle.text = c.title
                    homeBarView.progressView.setCompletionRate(completionRate)
                    homeBarView.progressRate.text = completionRate.label

                    self.stackView.addArrangedSubview(homeBarView)
                }
            }
        }
    }

    func renderStatisticsView() {
        let numberOfWorkouts = RepositoryStream.sharedInstance.getNumberOfWorkouts()
        let lastWorkout = RepositoryStream.sharedInstance.getLastWorkout()

        let numberOfWorkoutsLast7Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-7)
        let numberOfWorkoutsLast31Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-31)

        self.totalWorkouts.text = String(numberOfWorkouts) + getNumberOfWorkoutsPostfix(numberOfWorkouts)

        if let w = lastWorkout {
            self.lastWorkout.text = String(Date.timeAgoSince(w.startTime))
        } else {
            self.lastWorkout.text = String("Never")
        }

        self.last7Days.text = String(numberOfWorkoutsLast7Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast7Days)
        self.last31Days.text = String(numberOfWorkoutsLast31Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast31Days)
    }

    func getNumberOfWorkoutsPostfix(_ count: Int) -> String {
        if (count == 1) {
            return " Workout"
        } else {
            return " Workouts"
        }
    }
    
    func requestReviewIfAllowed() {
        if #available(iOS 10.3, *) {
            if isAllowedToOpenStoreReview() {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    func isAllowedToOpenStoreReview() -> Bool {
        let LAUNCH_COUNT_SKREVIEW = 5
        let LAUNCH_COUNT_USER_DEFAULTS_KEY = "LaunchCountUserDefaultsKey"
        
        let launchCount = Foundation.UserDefaults.standard.integer(forKey: LAUNCH_COUNT_USER_DEFAULTS_KEY)
        
        if launchCount >= LAUNCH_COUNT_SKREVIEW {
            return true
        } else {
            Foundation.UserDefaults.standard.set((launchCount + 1), forKey: LAUNCH_COUNT_USER_DEFAULTS_KEY)
        }
        
        return false
    }
    
    @IBAction func routine(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Choose Workout Routine",
            message: nil,
            preferredStyle: .actionSheet)

        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.barButtonItem = sender;
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Bodyweight Fitness", style: .default) { (action) in
            RoutineStream.sharedInstance.setRoutine("routine0")
        })
        
        alertController.addAction(UIAlertAction(title: "Starting Stretching", style: .default) { (action) in
            RoutineStream.sharedInstance.setRoutine("d8a722a0-fae2-4e7e-a751-430348c659fe")
        })
        
        alertController.addAction(UIAlertAction(title: "Molding Mobility", style: .default) { (action) in
            RoutineStream.sharedInstance.setRoutine("e73593f4-ee17-4b9b-912a-87fa3625f63d")
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startWorkout(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Workout", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(
            withIdentifier: "WorkoutNavigationController"
        ) as! WorkoutNavigationController
        
        navigationController?.present(
            destination,
            animated: true,
            completion: nil
        )
    }
    
    @IBAction func readMore(_ sender: AnyObject) {
        if let requestUrl = URL(string: RoutineStream.sharedInstance.routine.url) {
            UIApplication.shared.openURL(requestUrl)
        }
    }
}
