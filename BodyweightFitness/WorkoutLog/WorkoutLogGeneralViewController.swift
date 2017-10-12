import UIKit

import Charts

class WorkoutLogGeneralViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        setupChart()
        setChart(unitsSold)
    }
    
    func setupChart() {
        lineChartView.backgroundColor = UIColor.white
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = false
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
    
    func setChart(_ values: [Double]) {
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<values.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(values[i]))
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: nil)
        let lineChartData = LineChartData()
        
        lineChartDataSet.mode = .cubicBezier
        lineChartDataSet.cubicIntensity = 0.2
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawValuesEnabled = false
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.colors = [UIColor.primary()]
        
        lineChartData.addDataSet(lineChartDataSet)
        
        lineChartView.data = lineChartData
    }
}
