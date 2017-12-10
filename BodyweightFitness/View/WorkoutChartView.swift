import UIKit
import Charts

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

    func setValues(values: [RepositoryRoutine]) {
        let dataEntriesCompanion = DataEntriesCompanion()
        let dataEntries = dataEntriesCompanion.getDataEntries(
                fromDate: Date(),
                numberOfDays: workoutChartLength,
                repositoryRoutines: values,
                workoutChartType: self.workoutChartType
        )

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
            titleLabel?.text = data.title
            valueLabel?.text = data.label
        }
    }
}
