import UIKit
import RxSwift

class HomeViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cardView: UIView!

    @IBOutlet weak var totalWorkouts: UILabel!
    @IBOutlet weak var lastWorkout: UILabel!
    @IBOutlet weak var last7Days: UILabel!
    @IBOutlet weak var last31Days: UILabel!
    
    init() {
        super.init(nibName: "HomeView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()

        self.stackView.axis = UILayoutConstraintAxis.Vertical;
        self.stackView.distribution = UIStackViewDistribution.EqualSpacing;
        self.stackView.alignment = UIStackViewAlignment.Top;
        self.stackView.spacing = 0;

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribeNext({ (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
        })

        _ = RoutineStream.sharedInstance.routineObservable().subscribeNext({ (it) in
            self.renderWorkoutProgressView()
            self.renderStatisticsView()
            
            self.tabBarController?.title = it.title
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "plus"),
                landscapeImagePhone: nil,
                style: .Plain,
                target: self,
                action: #selector(routine))

        self.tabBarController?.title = "Bodyweight Fitness"
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
            self.lastWorkout.text = String(NSDate.timeAgoSince(w.startTime))
        } else {
            self.lastWorkout.text = String("Never")
        }

        self.last7Days.text = String(numberOfWorkoutsLast7Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast7Days)
        self.last31Days.text = String(numberOfWorkoutsLast31Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast31Days)
    }

    func getNumberOfWorkoutsPostfix(count: Int) -> String {
        if (count == 1) {
            return " Workout"
        } else {
            return " Workouts"
        }
    }
    
    func routine(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "Choose Workout Routine",
            message: nil,
            preferredStyle: .ActionSheet)

        alertController.modalPresentationStyle = .Popover
        alertController.popoverPresentationController?.barButtonItem = sender;
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Bodyweight Fitness", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("routine0")
        })
        
        alertController.addAction(UIAlertAction(title: "Molding Mobility", style: .Default) { (action) in
            RoutineStream.sharedInstance.setRoutine("e73593f4-ee17-4b9b-912a-87fa3625f63d")
        })
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func startWorkout(sender: AnyObject) {
        let backItem = UIBarButtonItem()
        backItem.title = "Home"

        self.tabBarController?.navigationItem.backBarButtonItem = backItem
        self.showViewController(WorkoutViewController(), sender: nil)
    }
}
