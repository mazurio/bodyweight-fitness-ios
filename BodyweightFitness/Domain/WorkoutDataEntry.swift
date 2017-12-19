import Charts

class WorkoutDataEntry: ChartDataEntry {
    var title: String?
    var label: String?

    public required init() {
        super.init()
    }

    init(x: Double, y: Double, title: String? = nil, label: String? = nil) {
        super.init(x: x, y: y)

        self.title = title
        self.label = label
    }
}
