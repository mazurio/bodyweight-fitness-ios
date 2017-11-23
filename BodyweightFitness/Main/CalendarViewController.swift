import UIKit
import RealmSwift
import JTAppleCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var tableView: UITableView!

    var date: Date = Date()
    var routines: Results<RepositoryRoutine>?

    let formatter = DateFormatter()
    var testCalendar: Calendar! = Calendar.current
    
    override func viewDidLoad() {
        self.setNavigationBar()
        
        let border = CALayer()
        let width = CGFloat(0.5)

        border.borderColor = UIColor(
            red: 70.0/255.0,
            green: 70.0/255.0,
            blue: 80.0/255.0,
            alpha: 1.0
        ).cgColor
        
        border.frame = CGRect(
                x: 0,
                y: self.backgroundView.frame.size.height - width,
                width:  self.backgroundView.frame.size.width,
                height: self.backgroundView.frame.size.height)

        border.borderWidth = width

        self.backgroundView.layer.addSublayer(border)
        self.backgroundView.layer.masksToBounds = true

        self.tableView.register(
                UINib(nibName: "WorkoutLogSectionCell", bundle: nil),
                forCellReuseIdentifier: "WorkoutLogSectionCell"
        )

        self.tableView.register(
                UINib(nibName: "WorkoutLogCardCell", bundle: nil),
                forCellReuseIdentifier: "WorkoutLogCardCell"
        )

        self.tableView.delegate = self
        self.tableView.dataSource = self

        formatter.dateFormat = "yyyy MM dd"

        self.calendarView.calendarDelegate = self
        self.calendarView.calendarDataSource = self
        self.calendarView.allowsMultipleSelection = false
        self.calendarView.scrollingMode = .stopAtEachCalendarFrameWidth
        self.calendarView.isRangeSelectionUsed = false
        self.calendarView.reloadData()

        self.calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false) {
            self.calendarView.selectDates([Date()])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showOrHideCardViewForDate(date)
    }
    
    @IBAction func toggleCurrentDayView(_ sender: UIBarButtonItem) {
        self.calendarView.scrollToDate(Date(), animateScroll: false)
        self.calendarView.selectDates([Date()])
    }

    func showOrHideCardViewForDate(_ date: Date) {
        self.date = date

        self.navigationItem.title = date.commonDescription
        
        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(date)
        if (routines.count > 0) {
            self.routines = routines
            self.tableView?.backgroundView = nil
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))

            label.text = "When you log a workout, you'll see it here."
            label.font = UIFont(name: "Helvetica Neue", size: 15)
            label.textAlignment = .center
            label.sizeToFit()

            self.routines = nil
            self.tableView?.backgroundView = label
        }

        self.tableView.reloadData()
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = self.routines {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let routines = self.routines {
            return routines.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutLogCardCell", for: indexPath) as! WorkoutLogCardCell
        
        if let routines = self.routines {
            let repositoryRoutine = routines[indexPath.row]

            let companion = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises)
            let completionRate = companion.completionRate()
            
            cell.parentController = self
            cell.date = date
            
            cell.title.text = repositoryRoutine.title
            cell.subtitle.text = repositoryRoutine.subtitle
            cell.progressView.setCompletionRate(completionRate)
            cell.progressRate.text = completionRate.label
            
            cell.repositoryRoutine = repositoryRoutine
        }
        
        return cell
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        let startDate = formatter.date(from: "2015 01 01")
        let endDate = Date()
        
        let parameters = ConfigurationParameters(startDate: startDate!,
                                                 endDate: endDate,
                                                 numberOfRows: 1,
                                                 calendar: testCalendar,
                                                 generateInDates: .forFirstMonthOnly,
                                                 generateOutDates: .off,
                                                 firstDayOfWeek: .monday,
                                                 hasStrictBoundaries: false)
        
        return parameters
    }
    
    public func calendar(
        _ calendar: JTAppleCalendar.JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: JTAppleCalendar.CellState,
        indexPath: IndexPath) -> JTAppleCalendar.JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "CellView",
            for: indexPath) as! CellView
        
        cell.setupCellBeforeDisplay(cellState, date: date)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)
        
        self.showOrHideCardViewForDate(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let today: Date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let visibleD = visibleDates.monthDates.map({ (date: Date, _) -> Date in
            date
        })
        
        if visibleD.contains(today) {
            calendar.selectDates([today])
        } else {
            if let f = visibleD.first {
                calendar.selectDates([f])
            }
        }
    }
}
