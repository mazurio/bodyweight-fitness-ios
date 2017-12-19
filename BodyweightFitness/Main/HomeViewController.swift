import UIKit
import RxSwift
import StoreKit
import SnapKit
import MessageUI

class HomeViewController: AbstractViewController, MFMailComposeViewControllerDelegate {
    var routine: Routine? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        _ = RoutineStream.sharedInstance.repositoryObservable().subscribe(onNext: { (it) in
            self.initializeContent()
        })

        _ = RoutineStream.sharedInstance.routineObservable().subscribe(onNext: { (it) in
            self.routine = it
            self.initializeContent()
        })
        
        self.requestReviewIfAllowed()
    }

    override func initializeContent() {
        super.initializeContent()

        self.navigationItem.title = self.routine?.title
        
        self.addView(self.createTodaysProgressCard())
        self.addView(self.createAboutRoutineCard())
        self.addView(self.createStatisticsCard())
        self.addView(self.createFeedbackCard())
    }
    
    func createTodaysProgressCard() -> CardView {
        let card = CardView()
        
        let label = TitleLabel()
        label.text = "Today's Progress"
        card.addSubview(label)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)
        
        if (RepositoryStream.sharedInstance.repositoryRoutineForTodayExists()) {
            let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
            
            for repositoryCategory in repositoryRoutine.categories {
                let companion = ListOfRepositoryExercisesCompanion(repositoryCategory.exercises)
                let completionRate = companion.completionRate()

                let homeBarView = HomeBarView()
                
                homeBarView.categoryTitle.text = repositoryCategory.title
                homeBarView.progressView.setCompletionRate(completionRate)
                homeBarView.progressRate.text = completionRate.label
                
                stackView.addArrangedSubview(homeBarView)
            }
        } else {
            if let routine = self.routine {
                for category in routine.categories {
                    if let c = category as? Category {
                        let completionRate = CompletionRate(percentage: 0, label: "0%")
                        let homeBarView = HomeBarView()
                        
                        homeBarView.categoryTitle.text = c.title
                        homeBarView.progressView.setCompletionRate(completionRate)
                        homeBarView.progressRate.text = completionRate.label
                        
                        stackView.addArrangedSubview(homeBarView)
                    }
                }
            }
        }
        
        let cardButton = CardButton()
        cardButton.setTitle("Start Workout", for: .normal)
        cardButton.addTarget(self, action: #selector(startWorkout), for: .touchUpInside)
        card.addSubview(cardButton)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
        }
        
        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
        }
        
        cardButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
            
            make.height.equalTo(36)
        }
        
        return card
    }
    
    func createAboutRoutineCard() -> CardView {
        let card = CardView()
        
        let routineTitleLabel = TitleLabel()
        routineTitleLabel.text = routine?.title
        card.addSubview(routineTitleLabel)
        
        let routineShortDescriptionLabel = DescriptionTextView()
        routineShortDescriptionLabel.text = routine?.shortDescription
        card.addSubview(routineShortDescriptionLabel)
        
        let cardButton = CardButton()
        cardButton.setTitle("Read More", for: .normal)
        cardButton.addTarget(self, action: #selector(readMore), for: .touchUpInside)
        card.addSubview(cardButton)
        
        routineTitleLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            
            make.height.equalTo(24)
        }
        
        routineShortDescriptionLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(routineTitleLabel.snp.bottom) //.offset(8)
            make.left.equalTo(card).offset(12)
            make.right.equalTo(card).offset(-12)
            make.bottom.equalTo(cardButton.snp.top).offset(-12)
        }
        
        cardButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
            
            make.height.equalTo(36)
        }
        
        return card
    }
    
    func createStatisticsCard() -> CardView {
        let card = CardView()
        
        let numberOfWorkouts = RepositoryStream.sharedInstance.getNumberOfWorkouts()
        let lastWorkout = RepositoryStream.sharedInstance.getLastWorkout()
        
        let numberOfWorkoutsLast7Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-7)
        let numberOfWorkoutsLast31Days = RepositoryStream.sharedInstance.getNumberOfWorkouts(-31)
        
        let topLeftLabel = TitleLabel()
        topLeftLabel.textAlignment = .left
        topLeftLabel.text = String(numberOfWorkouts) + getNumberOfWorkoutsPostfix(numberOfWorkouts)
        card.addSubview(topLeftLabel)
        
        let topLeftValue = ValueLabel()
        topLeftValue.textAlignment = .left
        topLeftValue.text = "Total Workouts"
        card.addSubview(topLeftValue)
        
        let topRightLabel = TitleLabel()
        topRightLabel.textAlignment = .right
        
        if let workout = lastWorkout {
            topRightLabel.text = String(Date.timeAgoSince(workout.startTime))
        } else {
            topRightLabel.text = String("Never")
        }
        
        card.addSubview(topRightLabel)
        
        let topRightValue = ValueLabel()
        topRightValue.textAlignment = .right
        topRightValue.text = "Last Workout"
        card.addSubview(topRightValue)
        
        let bottomLeftLabel = TitleLabel()
        bottomLeftLabel.textAlignment = .left
        bottomLeftLabel.text = String(numberOfWorkoutsLast7Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast7Days)
        card.addSubview(bottomLeftLabel)
        
        let bottomLeftValue = ValueLabel()
        bottomLeftValue.textAlignment = .left
        bottomLeftValue.text = "Last 7 Days"
        card.addSubview(bottomLeftValue)
        
        let bottomRightLabel = TitleLabel()
        bottomRightLabel.textAlignment = .right
        bottomRightLabel.text = String(numberOfWorkoutsLast31Days) + getNumberOfWorkoutsPostfix(numberOfWorkoutsLast31Days)
        card.addSubview(bottomRightLabel)
        
        let bottomRightValue = ValueLabel()
        bottomRightValue.textAlignment = .right
        bottomRightValue.text = "Last 31 Days"
        card.addSubview(bottomRightValue)
        
        topLeftLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.leading.equalTo(card).offset(16)
            
            make.right.equalTo(topRightLabel.snp.left)
            
            make.height.equalTo(24)
        }
        
        topRightLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.trailing.equalTo(card).offset(-16)
            
            make.left.equalTo(topLeftLabel.snp.right)
            
            make.height.equalTo(24)
        }
        
        topLeftValue.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLeftLabel.snp.bottom).offset(8)
            make.leading.equalTo(card).offset(16)
            
            make.right.equalTo(topRightValue.snp.left)
        }
        
        topRightValue.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topRightLabel.snp.bottom).offset(8)
            make.trailing.equalTo(card).offset(-16)
            
            make.left.equalTo(topLeftValue.snp.right)
        }
        
        bottomLeftLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLeftValue.snp.bottom).offset(20)
            make.leading.equalTo(card).offset(16)
            
            make.right.equalTo(bottomRightLabel.snp.left)
            
            make.height.equalTo(24)
        }
        
        bottomRightLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topRightValue.snp.bottom).offset(20)
            make.trailing.equalTo(card).offset(-16)
            
            make.left.equalTo(bottomLeftLabel.snp.right)
            
            make.height.equalTo(24)
        }
        
        bottomLeftValue.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bottomLeftLabel.snp.bottom).offset(8)
            make.leading.equalTo(card).offset(16)
            
            make.right.equalTo(bottomRightValue.snp.left)
            
            make.bottom.equalTo(card).offset(-20)
        }
        
        bottomRightValue.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(bottomRightLabel.snp.bottom).offset(8)
            make.trailing.equalTo(card).offset(-16)
            
            make.left.equalTo(bottomLeftValue.snp.right)
            
            make.bottom.equalTo(card).offset(-20)
        }
        
        return card
    }

    func createFeedbackCard() -> CardView {
        let card = CardView()

        let label = TitleLabel()
        label.text = "Feedback"
        card.addSubview(label)

        let description = DescriptionTextView()
        description.text = "Found a bug? Would like to request a new feature? Let me know!"
        card.addSubview(description)

        let cardButton = CardButton()
        cardButton.setTitle("Send Email", for: .normal)
        cardButton.addTarget(self, action: #selector(sendFeedback), for: .touchUpInside)
        card.addSubview(cardButton)

        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)

            make.height.equalTo(24)
        }

        description.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom)
            make.left.equalTo(card).offset(12)
            make.right.equalTo(card).offset(-12)
            make.bottom.equalTo(cardButton.snp.top).offset(-12)
        }

        cardButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        return card
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
            UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
        }
    }

    @IBAction func sendFeedback(_ sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let emailController = MFMailComposeViewController()

            emailController.mailComposeDelegate = self
            emailController.setToRecipients(["damian@mazur.io"])
            emailController.setSubject("Bodyweight Fitness App for iOS - Feedback")
            emailController.setMessageBody("Hi Damian,\n", isHTML: false)

            self.present(emailController, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
