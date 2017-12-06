import SnapKit
import Charts
import RealmSwift

extension WorkoutLogGeneralViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let data = repositoryRoutine as? RepositoryRoutine {
            print("\(entry.x) \(entry.y) with data \(data.startTime)")
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
    
    func initializeContent() {
        self.removeAllViews()

        if let repositoryRoutine = self.repositoryRoutine {
            self.addView(self.createStatisticsCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Workout Progress"))
            self.addView(self.createProgressCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Workout Length History"))
            self.addView(self.createWorkoutLengthHistoryCard(repositoryRoutine: repositoryRoutine))
            self.addView(ValueLabel.create(text: "Completion Rate History"))
            self.addView(self.createCompletionRateHistoryCard())
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

        let values = Array(allWorkouts).map({
            (repositoryRoutine: $0, workoutLength: RepositoryRoutineCompanion($0).workoutLengthInMinutes())
        })

        let graph = LineChartView()
        card.addSubview(graph)

        setupChart(graph)
        setChart(values, lineChartView: graph)

        let label = TitleLabel()
        label.text = "{{date}}"
        card.addSubview(label)

        let value = ValueLabel()
        value.text = "11%"
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

    func setupChart(_ lineChartView: LineChartView) {
        lineChartView.delegate = self
        lineChartView.backgroundColor = UIColor.white
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = true
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.drawMarkers = false
        lineChartView.legend.enabled = false
        lineChartView.animate(
                xAxisDuration: 1.0,
                yAxisDuration: 1.0,
                easingOption: .easeInSine
        )

        lineChartView.xAxis.enabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false

        lineChartView.leftAxis.enabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false

        lineChartView.rightAxis.enabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
    }

    func setChart(_ values: [(repositoryRoutine: RepositoryRoutine, workoutLength: Double)], lineChartView: LineChartView) {
        var dataEntries: [ChartDataEntry] = []

        for (index, entry) in values.enumerated() {
            let dataEntry = ChartDataEntry(
                    x: Double(index),
                    y: entry.workoutLength,
                    data: entry.repositoryRoutine
            )

            dataEntries.append(dataEntry)
        }

        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: nil)
        lineChartDataSet.lineWidth = 1.8
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.cubicIntensity = 0.2
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.colors = [UIColor.primary()]

        let lineChartData = LineChartData()
        lineChartData.addDataSet(lineChartDataSet)

        lineChartView.data = lineChartData
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
