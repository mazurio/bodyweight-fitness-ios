import SnapKit

class WorkoutLogCategoryViewController: AbstractViewController {
    var repositoryRoutine: RepositoryRoutine?
    var repositoryCategory: RepositoryCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = RoutineStream.sharedInstance.repositoryObservable().subscribe(onNext: { (it) in
            self.initializeContent()
        })
        
        self.initializeContent()
    }
    
    func initializeContent() {
        self.removeAllViews()
        
        if let repositoryCategory = self.repositoryCategory {
            self.addView(self.createProgressCard(repositoryCategory: repositoryCategory))
            self.addView(ValueLabel.create(text: "Category Completion Rate"))
            self.addView(self.createCompletionRateHistoryCard())
            
            for repositorySection in repositoryCategory.sections {
                self.addView(ValueLabel.create(text: repositorySection.title))

                let companion = ListOfRepositoryExercisesCompanion(repositorySection.exercises)

                for repositoryExercise in companion.visibleOrCompletedExercises() {
                    self.addView(
                        createExerciseCard(repositoryExercise: repositoryExercise)
                    )
                }
            }
        }
    }
    
    func createProgressCard(repositoryCategory: RepositoryCategory) -> CardView {
        let card = CardView()

        let companion = ListOfRepositoryExercisesCompanion(repositoryCategory.exercises)
        let completionRate = companion.completionRate()

        let topLeftLabel = TitleLabel()
        topLeftLabel.textAlignment = .left
        topLeftLabel.text = "\(companion.numberOfCompletedExercises()) out of \(companion.numberOfExercises())"
        card.addSubview(topLeftLabel)
        
        let topLeftValue = ValueLabel()
        topLeftValue.textAlignment = .left
        topLeftValue.text = "Completed Exercises"
        card.addSubview(topLeftValue)
        
        let topRightLabel = TitleLabel()
        topRightLabel.textAlignment = .right
        topRightLabel.text = completionRate.label
        
        card.addSubview(topRightLabel)
        
        let topRightValue = ValueLabel()
        topRightValue.textAlignment = .right
        topRightValue.text = "Completion Rate"
        card.addSubview(topRightValue)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)

        for repositorySection in repositoryCategory.sections {
            let companion = ListOfRepositoryExercisesCompanion(repositorySection.exercises)
            let completionRate = companion.completionRate()

            let homeBarView = HomeBarView()
            homeBarView.categoryTitle.text = repositorySection.title
            homeBarView.progressView.setCompletionRate(completionRate)
            homeBarView.progressRate.text = completionRate.label

            stackView.addArrangedSubview(homeBarView)
        }

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

        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLeftValue.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
        }
        
        return card
    }
    
    func createCompletionRateHistoryCard() -> CardView {
        let card = CardView()

        let label = TitleLabel()
        label.text = "12 October 2017"
        card.addSubview(label)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-20)
        }
        
        return card
    }
    
    func createExerciseCard(repositoryExercise: RepositoryExercise) -> CardView {
        let card = CardView()

        let companion = RepositoryExerciseCompanion(repositoryExercise)

        let label = TitleLabel()
        label.text = repositoryExercise.title
        card.addSubview(label)
        
        let value = ValueLabel()
        value.text = companion.setSummaryLabel()
        card.addSubview(value)

        let button = CardButton()
        button.repositoryExercise = repositoryExercise
        button.setTitle("Edit", for: .normal)
        button.addTarget(self, action: #selector(edit(_:)), for: .touchUpInside)
        card.addSubview(button)

        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
        }
        
        value.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
        }

        button.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(value.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }
        
        return card
    }

    @IBAction func edit(_ sender: CardButton) {
        let controller = self.parent!

        if let exercise = sender.repositoryExercise {
            let logWorkoutController = LogWorkoutController()
            
            logWorkoutController.parentController = controller
            logWorkoutController.exercise = exercise
            logWorkoutController.routine = repositoryRoutine
            
            logWorkoutController.modalTransitionStyle = .coverVertical
            logWorkoutController.modalPresentationStyle = .custom
            
            controller.dim(.in, alpha: 0.5, speed: 0.5)
            controller.present(logWorkoutController, animated: true, completion: nil)
        }
    }
}

