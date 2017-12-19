import SnapKit
import Charts
import RealmSwift

class WorkoutLogGeneralViewController: AbstractViewController {
    var repositoryRoutine: RepositoryRoutine?

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribe(onNext: { (it) in
            self.initializeContent()
        })
        
        self.initializeContent()
    }

    override func initializeContent() {
        super.initializeContent()

        if let repositoryRoutine = self.repositoryRoutine {
            self.addView(self.createStatisticsCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Workout Progress"))
            self.addView(self.createProgressCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Workout Length History"))
            self.addView(self.createWorkoutLengthHistoryCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Completion Rate History"))
            self.addView(self.createCompletionRateHistoryCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Not Completed Exercises"))
            self.addView(self.createNotCompletedExercisesCard(repositoryRoutine: repositoryRoutine))
        }
    }
    
    func createTitleValueView(labelText: String, valueText: String) -> UIView {
        let view = UIView()
        
        let label = TitleLabel()
        label.text = labelText
        view.addSubview(label)
        
        let value = ValueLabel()
        value.text = valueText
        view.addSubview(value)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        value.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        return view
    }
    
    func createStatisticsCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let companion = RepositoryRoutineCompanion(repositoryRoutine)

        let topLeftLabel = TitleLabel()
        topLeftLabel.textAlignment = .left
        topLeftLabel.text = companion.startTime()
        card.addSubview(topLeftLabel)
        
        let topLeftValue = ValueLabel()
        topLeftValue.textAlignment = .left
        topLeftValue.text = "Start Time"
        card.addSubview(topLeftValue)
        
        let topRightLabel = TitleLabel()
        topRightLabel.textAlignment = .right
        topRightLabel.text = companion.lastUpdatedTime()
        
        card.addSubview(topRightLabel)
        
        let topRightValue = ValueLabel()
        topRightValue.textAlignment = .right
        topRightValue.text = companion.lastUpdatedTimeLabel()
        card.addSubview(topRightValue)
        
        let bottomLeftLabel = TitleLabel()
        bottomLeftLabel.textAlignment = .left
        bottomLeftLabel.text = companion.workoutLength()
        card.addSubview(bottomLeftLabel)
        
        let bottomLeftValue = ValueLabel()
        bottomLeftValue.textAlignment = .left
        bottomLeftValue.text = "Workout Length"
        card.addSubview(bottomLeftValue)
        
        let bottomRightLabel = TitleLabel()
        bottomRightLabel.textAlignment = .right
        bottomRightLabel.text = " "
        card.addSubview(bottomRightLabel)
        
        let bottomRightValue = ValueLabel()
        bottomRightValue.textAlignment = .right
        bottomRightValue.text = " "
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
    
    func createProgressCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let companion = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises)
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
        
        for repositoryCategory in repositoryRoutine.categories {
            let companion = ListOfRepositoryExercisesCompanion(repositoryCategory.exercises)
            let completionRate = companion.completionRate()
            
            let homeBarView = HomeBarView()
            homeBarView.categoryTitle.text = repositoryCategory.title
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
    
    func createWorkoutLengthHistoryCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let realm = try! Realm()
        let allWorkouts = realm.objects(RepositoryRoutine.self)
                .filter("routineId == '\(repositoryRoutine.routineId)'")

        let label = TitleLabel()
        label.text = RepositoryRoutineCompanion(repositoryRoutine).date()

        let value = ValueLabel()
        value.text = RepositoryRoutineCompanion(repositoryRoutine).workoutLength()

        let buttonBar = UIView()
        buttonBar.backgroundColor = UIColor.primary()

        let graph = WorkoutChartView()
        graph.workoutChartType = .WorkoutLength
        graph.workoutChartLength = 7
        graph.values = Array(allWorkouts)
        graph.titleLabel = label
        graph.valueLabel = value
        graph.buttonBar = buttonBar
        graph.setValues()

        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(graph, action: #selector(graph.segmentedControlValueChanged(_:)), for: UIControlEvents.valueChanged)
        segmentedControl.insertSegment(withTitle: "1W", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "1M", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "3M", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "6M", at: 3, animated: true)
        segmentedControl.insertSegment(withTitle: "1Y", at: 4, animated: true)
        segmentedControl.insertSegment(withTitle: "ALL", at: 5, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.lightGray
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.primary()
        ], for: .selected)

        card.addSubview(label)
        card.addSubview(value)
        card.addSubview(graph)
        card.addSubview(segmentedControl)
        card.addSubview(buttonBar)

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

        graph.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(value.snp.bottom).offset(8)
            make.left.equalTo(card).offset(0)
            make.right.equalTo(card).offset(0)

            make.height.equalTo(200)
        }

        segmentedControl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(graph.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        buttonBar.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.equalTo(segmentedControl.snp.left)
            make.bottom.equalTo(card).offset(-16)

            make.width.equalTo(segmentedControl.snp.width).multipliedBy(1 / CGFloat(segmentedControl.numberOfSegments))

            make.height.equalTo(2)
        }
        
        return card
    }
    
    func createCompletionRateHistoryCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let realm = try! Realm()
        let allWorkouts = realm.objects(RepositoryRoutine.self)
                .filter("routineId == '\(repositoryRoutine.routineId)'")

        let label = TitleLabel()
        label.text = RepositoryRoutineCompanion(repositoryRoutine).date()

        let value = ValueLabel()
        value.text = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises).completionRate().label

        let buttonBar = UIView()
        buttonBar.backgroundColor = UIColor.primary()

        let graph = WorkoutChartView()
        graph.workoutChartType = .CompletionRate
        graph.workoutChartLength = 7
        graph.values = Array(allWorkouts)
        graph.titleLabel = label
        graph.valueLabel = value
        graph.buttonBar = buttonBar
        graph.setValues()

        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(graph, action: #selector(graph.segmentedControlValueChanged(_:)), for: UIControlEvents.valueChanged)
        segmentedControl.insertSegment(withTitle: "1W", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "1M", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "3M", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "6M", at: 3, animated: true)
        segmentedControl.insertSegment(withTitle: "1Y", at: 4, animated: true)
        segmentedControl.insertSegment(withTitle: "ALL", at: 5, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.lightGray
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.primary()
        ], for: .selected)

        card.addSubview(label)
        card.addSubview(value)
        card.addSubview(graph)
        card.addSubview(segmentedControl)
        card.addSubview(buttonBar)

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

        graph.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(value.snp.bottom).offset(8)
            make.left.equalTo(card).offset(0)
            make.right.equalTo(card).offset(0)

            make.height.equalTo(200)
        }

        segmentedControl.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(graph.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        buttonBar.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.equalTo(segmentedControl.snp.left)
            make.bottom.equalTo(card).offset(-16)

            make.width.equalTo(segmentedControl.snp.width).multipliedBy(1 / CGFloat(segmentedControl.numberOfSegments)).constraint

            make.height.equalTo(2)
        }

        return card
    }
    
    func createNotCompletedExercisesCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)

        let companion = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises)

        for repositoryExercise in companion.notCompletedExercises() {
            if let category = repositoryExercise.category, let section = repositoryExercise.section {
                stackView.addArrangedSubview(
                        createTitleValueView(
                                labelText: "\(repositoryExercise.title)",
                                valueText: "\(category.title) - \(section.title)"
                        )
                )
            }
        }
        
        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
        }
        
        return card
    }
}
