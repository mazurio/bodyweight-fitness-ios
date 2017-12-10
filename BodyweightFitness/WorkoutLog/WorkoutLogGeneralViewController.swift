import SnapKit
import Charts
import RealmSwift

enum WorkoutChartType {
    case WorkoutLength
    case CompletionRate
}

class WorkoutDataEntry: ChartDataEntry {
    var repositoryRoutine: RepositoryRoutine?

    public required init() {
        super.init()
    }

    init(x: Double, y: Double, repositoryRoutine: RepositoryRoutine) {
        super.init(x: x, y: y)

        self.repositoryRoutine = repositoryRoutine
    }
}

class WorkoutChartView: LineChartView, ChartViewDelegate {
    var workoutChartType: WorkoutChartType = .WorkoutLength
    var workoutChartLength: Int = 30

    var titleLabel: UILabel?
    var valueLabel: UILabel?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
    }

    func commonInit() {
        self.delegate = self
        self.backgroundColor = UIColor.white
        self.chartDescription?.enabled = false
        self.dragEnabled = true
        self.drawGridBackgroundEnabled = false
        self.drawMarkers = false
        self.legend.enabled = false
        self.animate(
                xAxisDuration: 1.0,
                yAxisDuration: 1.0,
                easingOption: .easeInSine
        )

        self.xAxis.enabled = false
        self.xAxis.drawLabelsEnabled = false
        self.xAxis.drawGridLinesEnabled = false

        self.leftAxis.enabled = false
        self.leftAxis.drawLabelsEnabled = false
        self.leftAxis.drawGridLinesEnabled = false

        self.rightAxis.enabled = false
        self.rightAxis.drawLabelsEnabled = false
        self.rightAxis.drawGridLinesEnabled = false
    }

    func setValues(values: Array<RepositoryRoutine>) {
        var dataEntries: [WorkoutDataEntry] = []

        for (index, repositoryRoutine) in values.enumerated() {
            dataEntries.append(
                    WorkoutDataEntry(
                            x: Double(index),
                            y: getYValue(repositoryRoutine: repositoryRoutine),
                            repositoryRoutine: repositoryRoutine
                    )
            )
        }

        self.data = self.createDataSetFromDataEntries(values: dataEntries)
    }

    func createDataSetFromDataEntries(values: [WorkoutDataEntry]) -> LineChartData {
        let lineChartData = LineChartData()
        let lineChartDataSet = LineChartDataSet(values: values, label: nil)

        lineChartDataSet.lineWidth = 1.8
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.cubicIntensity = 0.2
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.colors = [UIColor.primary()]

        lineChartData.addDataSet(lineChartDataSet)

        return lineChartData
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let data = entry as? WorkoutDataEntry {
            if let repositoryRoutine = data.repositoryRoutine {
                titleLabel?.text = getYTitle(repositoryRoutine: repositoryRoutine)
                valueLabel?.text = getYLabel(repositoryRoutine: repositoryRoutine)
            }
        }
    }

    func getYValue(repositoryRoutine: RepositoryRoutine) -> Double {
        switch workoutChartType {
        case .WorkoutLength:
            return RepositoryRoutineCompanion(repositoryRoutine).workoutLengthInMinutes()
        case .CompletionRate:
            return Double(ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises).completionRate().percentage)
        }
    }

    func getYTitle(repositoryRoutine: RepositoryRoutine) -> String {
        return RepositoryRoutineCompanion(repositoryRoutine).date()
    }

    func getYLabel(repositoryRoutine: RepositoryRoutine) -> String {
        switch workoutChartType {
        case .WorkoutLength:
            return RepositoryRoutineCompanion(repositoryRoutine).workoutLength()
        case .CompletionRate:
            return ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises).completionRate().label
        }
    }
}

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

        let label = TitleLabel()
        label.text = RepositoryRoutineCompanion(repositoryRoutine).date()

        let value = ValueLabel()
        value.text = RepositoryRoutineCompanion(repositoryRoutine).workoutLength()

        let graph = WorkoutChartView()

        graph.workoutChartType = .WorkoutLength
        graph.titleLabel = label
        graph.valueLabel = value

        graph.setValues(values: Array(allWorkouts))
        card.addSubview(graph)

        card.addSubview(label)
        card.addSubview(value)

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)

        let oneWeekButton = CardButton()
        oneWeekButton.setTitleColor(.black, for: .selected)
        oneWeekButton.setTitle("1W", for: .normal)
        stackView.addArrangedSubview(oneWeekButton)

        let oneMonthButton = CardButton()
        oneMonthButton.setTitle("1M", for: .normal)
        stackView.addArrangedSubview(oneMonthButton)

        let threeMonthsButton = CardButton()
        threeMonthsButton.setTitle("3M", for: .normal)
        stackView.addArrangedSubview(threeMonthsButton)

        let sixMonthsButton = CardButton()
        sixMonthsButton.setTitle("6M", for: .normal)
        stackView.addArrangedSubview(sixMonthsButton)

        let oneYearButton = CardButton()
        oneYearButton.setTitle("1Y", for: .normal)
        stackView.addArrangedSubview(oneYearButton)

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
//            make.bottom.equalTo(card).offset(0)

            make.height.equalTo(200)
        }

        stackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(graph.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-16)
        }
        
        return card
    }
    
    func createCompletionRateHistoryCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let realm = try! Realm()

        let allWorkouts = realm.objects(RepositoryRoutine.self)

        let label = TitleLabel()
        label.text = RepositoryRoutineCompanion(repositoryRoutine).date()

        let value = ValueLabel()
        value.text = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises).completionRate().label

        let graph = WorkoutChartView()

        graph.workoutChartType = .CompletionRate
        graph.titleLabel = label
        graph.valueLabel = value

        graph.setValues(values: Array(allWorkouts))
        card.addSubview(graph)

        card.addSubview(label)
        card.addSubview(value)

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
            make.bottom.equalTo(card).offset(0)

            make.height.equalTo(200)
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
