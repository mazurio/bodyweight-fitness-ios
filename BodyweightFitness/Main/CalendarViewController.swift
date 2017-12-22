import UIKit
import RealmSwift
import JTAppleCalendar
import MessageUI

class CalendarViewController: AbstractViewController, MFMailComposeViewControllerDelegate {
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
        self.calendarView.scrollingMode = .stopAtEachCalendarFrame
        self.calendarView.isRangeSelectionUsed = false
        self.calendarView.reloadData()

        self.calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false) {
            self.calendarView.selectDates([Date()])
        }

        _ = RoutineStream.sharedInstance.repositoryObservable().subscribe(onNext: { (it) in
            self.initializeContent(contentForDate: self.date)
        })
    }

    override func mainView() -> UIView {
        return self.listView
    }

    func initializeContent(contentForDate: Date) {
        super.initializeContent()

        self.navigationItem.title = contentForDate.commonDescription

        let repositoryRoutines = RepositoryStream.sharedInstance.getRoutinesForDate(contentForDate)

        if repositoryRoutines.isEmpty {
            self.addView(self.createEmptyStateCard())
        } else {
            for repositoryRoutine in repositoryRoutines {
                self.addView(self.createLogCard(repositoryRoutine: repositoryRoutine))
            }
        }
    }

    func createEmptyStateCard() -> CardView {
        let card = CardView()

        let label = ValueLabel()
        label.text = "No Logged Workouts"
        label.numberOfLines = 2
        label.textAlignment = .center
        card.addSubview(label)

        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(80)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-80)
        }

        return card
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
        viewButton.repositoryRoutine = repositoryRoutine
        viewButton.setTitle("View", for: .normal)
        viewButton.addTarget(self, action: #selector(viewWorkout), for: .touchUpInside)
        card.addSubview(viewButton)

        let exportButton = CardButton()
        exportButton.repositoryRoutine = repositoryRoutine
        exportButton.setTitle("Export", for: .normal)
        exportButton.addTarget(self, action: #selector(exportWorkout), for: .touchUpInside)
        card.addSubview(exportButton)

        let deleteButton = CardButton()
        deleteButton.repositoryRoutine = repositoryRoutine
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(UIColor.red, for: .normal)
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

    @IBAction func viewWorkout(_ sender: CardButton) {
        if let repositoryRoutine = sender.repositoryRoutine {
            let storyboard = UIStoryboard(name: "WorkoutLog", bundle: Bundle.main)

            let p = storyboard.instantiateViewController(withIdentifier: "WorkoutLogViewController") as! WorkoutLogViewController

            p.date = date
            p.repositoryRoutine = repositoryRoutine
            p.hidesBottomBarWhenPushed = true

            self.navigationController?.pushViewController(p, animated: true)
        }
    }

    @IBAction func exportWorkout(_ sender: CardButton) {
        if !MFMailComposeViewController.canSendMail() {
           print("Mail services are not available")
           return
        }

        guard let routine = sender.repositoryRoutine else {
            return
        }

        let weightUnit = getWeightUnit()

        let companion = RepositoryRoutineCompanion(routine)

        let subject = companion.emailSubject()
        let body = companion.emailBody(weightUnit: weightUnit)

        let csv = companion.csv(weightUnit: weightUnit)
        let csvName = companion.csvName()

        let emailViewController = configuredMailComposeViewController(subject: subject, messageBody: body, csv: data, csvName: csvName)
        self.present(emailViewController, animated: true, completion: nil)
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

                                RoutineStream.sharedInstance.setRepository()
                            }
                    )
            )

            self.present(alertController, animated: true, completion: nil)
        }
    }

    func configuredMailComposeViewController(subject: String, messageBody: String, csv: Data?, csvName: String) -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()

        emailController.mailComposeDelegate = self
        emailController.setSubject(subject)
        emailController.setMessageBody(messageBody, isHTML: false)

        if let data = csv {
            emailController.addAttachmentData(data, mimeType: "text/csv", fileName: csvName)
        }

        return emailController
    }

    // MARK: - MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func getWeightUnit() -> String {
        if PersistenceManager.getWeightUnit() == "lbs" {
            return "lbs"
        } else {
            return "kg"
        }
    }
}

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

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
    }
}
