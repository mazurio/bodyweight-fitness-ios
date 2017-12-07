import UIKit
import RealmSwift
import JTAppleCalendar

class CalendarViewController: AbstractViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var listView: UIView!

    var date: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBar()

        self.calendarView.calendarDelegate = self
        self.calendarView.calendarDataSource = self
        self.calendarView.allowsMultipleSelection = false
        self.calendarView.scrollingMode = .stopAtEachCalendarFrameWidth
        self.calendarView.isRangeSelectionUsed = false
        self.calendarView.reloadData()

        self.calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false) {
            self.calendarView.selectDates([Date()])
        }

        self.initializeContent(contentForDate: date)
    }

    override func mainView() -> UIView {
        return self.listView
    }

    func initializeContent(contentForDate: Date) {
        super.initializeContent()

        self.navigationItem.title = contentForDate.commonDescription

        let repositoryRoutines = RepositoryStream.sharedInstance.getRoutinesForDate(contentForDate)
        for repositoryRoutine in repositoryRoutines {
            self.addView(self.createLogCard(repositoryRoutine: repositoryRoutine))
        }
    }

    func createLogCard(repositoryRoutine: RepositoryRoutine) -> CardView {
        let card = CardView()

        let label = TitleLabel()
        label.text = repositoryRoutine.title
        card.addSubview(label)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stackView)

        let companion = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises)
        let completionRate = companion.completionRate()

        let homeBarView = HomeBarView()

        homeBarView.categoryTitle.text = repositoryRoutine.subtitle
        homeBarView.progressView.setCompletionRate(completionRate)
        homeBarView.progressRate.text = completionRate.label

        stackView.addArrangedSubview(homeBarView)

        let viewButton = CardButton()
        viewButton.setTitle("View", for: .normal)
        card.addSubview(viewButton)

        let exportButton = CardButton()
        exportButton.setTitle("Export", for: .normal)
        card.addSubview(exportButton)

        let deleteButton = CardButton()
        deleteButton.repositoryRoutine = repositoryRoutine
        deleteButton.setTitleColor(UIColor.red, for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.addTarget(self, action: #selector(removeLoggedWorkout), for: .touchUpInside)
        card.addSubview(deleteButton)

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

        viewButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.left.equalTo(card).offset(16)
            make.bottom.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        exportButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.left.equalTo(viewButton.snp.right).offset(16)
            make.bottom.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        deleteButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.left.equalTo(exportButton.snp.right).offset(16)
            make.bottom.equalTo(card).offset(-16)

            make.height.equalTo(36)
        }

        return card
    }

    @IBAction func toggleCurrentDayView(_ sender: UIBarButtonItem) {
        self.calendarView.scrollToDate(Date(), animateScroll: false)
        self.calendarView.selectDates([Date()])
    }

    @IBAction func removeLoggedWorkout(_ sender: CardButton) {
        if let repositoryRoutine = sender.repositoryRoutine {
            let alertController = UIAlertController(
                    title: "Remove Workout",
                    message: "Are you sure you want to remove this workout?",
                    preferredStyle: UIAlertControllerStyle.alert
            )

            alertController.addAction(
                    UIAlertAction(
                            title: "Cancel",
                            style: UIAlertActionStyle.cancel,
                            handler: nil
                    )
            )

            alertController.addAction(
                    UIAlertAction(
                            title: "Remove",
                            style: UIAlertActionStyle.destructive,
                            handler: { (action: UIAlertAction!) in
                                let realm = try! Realm()

                                try! realm.write {
                                    realm.delete(repositoryRoutine)
                                }

                                self.initializeContent(contentForDate: self.date)

                                RoutineStream.sharedInstance.setRepository()
                            }
                    )
            )

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func showOrHideCardViewForDate(_ date: Date) {
        self.initializeContent()
//        self.date = date
//
//        self.navigationItem.title = date.commonDescription
//
//        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(date)
//        if (routines.count > 0) {
//            self.routines = routines
//            self.tableView?.backgroundView = nil
//        } else {
//            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//
//            label.text = "When you log a workout, you'll see it here."
//            label.font = UIFont(name: "Helvetica Neue", size: 15)
//            label.textAlignment = .center
//            label.sizeToFit()
//
//            self.routines = nil
//            self.tableView?.backgroundView = label
//        }
//
//        self.tableView.reloadData()
    }
}
// to be rewritten

//extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if let _ = self.routines {
//            return 1
//        } else {
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let routines = self.routines {
//            return routines.count
//        } else {
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutLogCardCell", for: indexPath) as! WorkoutLogCardCell
//
//        if let routines = self.routines {
//            let repositoryRoutine = routines[indexPath.row]
//
//            let companion = ListOfRepositoryExercisesCompanion(repositoryRoutine.exercises)
//            let completionRate = companion.completionRate()
//
//            cell.parentController = self
//            cell.date = date
//
//            cell.title.text = repositoryRoutine.title
//            cell.subtitle.text = repositoryRoutine.subtitle
//            cell.progressView.setCompletionRate(completionRate)
//            cell.progressRate.text = completionRate.label
//
//            cell.repositoryRoutine = repositoryRoutine
//        }
//
//        return cell
//    }
//}

extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        let testCalendar = Calendar.current

        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = testCalendar.timeZone
        formatter.locale = testCalendar.locale
        
        let startDate = formatter.date(from: "2015 01 01")
        let endDate = Date()

        return ConfigurationParameters(
                startDate: startDate!,
                endDate: endDate,
                numberOfRows: 1,
                calendar: testCalendar,
                generateInDates: .forFirstMonthOnly,
                generateOutDates: .off,
                firstDayOfWeek: .monday,
                hasStrictBoundaries: false
        )
    }
    
    public func calendar(
        _ calendar: JTAppleCalendar.JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: JTAppleCalendar.CellState,
        indexPath: IndexPath
    ) -> JTAppleCalendar.JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "CellView",
            for: indexPath
        ) as! CellView
        
        cell.setupCellBeforeDisplay(cellState, date: date)
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)

        self.date = date
        self.initializeContent(contentForDate: date)
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
