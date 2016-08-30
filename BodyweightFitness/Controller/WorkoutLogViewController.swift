import UIKit
import RealmSwift

class WorkoutLogViewController: UIViewController,
        CVCalendarViewDelegate,
        CVCalendarMenuViewDelegate,
        CVCalendarViewAppearanceDelegate,
        UITableViewDataSource,
        UITableViewDelegate {

    @IBOutlet weak var backgroundView: UIView!

    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!

    @IBOutlet var tableView: UITableView!

    var date: NSDate? = NSDate()
    var routines: Results<RepositoryRoutine>?

    init() {
        super.init(nibName: "WorkoutLogView", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.setNavigationBar()

        let menuItem = UIBarButtonItem(
                image: UIImage(named: "menu"),
                landscapeImagePhone: nil,
                style: .Plain,
                target: self,
                action: #selector(dismiss))

        
        menuItem.tintColor = UIColor.primaryDark()

        let calendarItem = UIBarButtonItem(
            image: UIImage(named: "calendar"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(toggleCurrentDayView))
        
        calendarItem.tintColor = UIColor.primaryDark()
        
        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.rightBarButtonItem = calendarItem
        
        self.navigationItem.title = CVDate(date: date!).commonDescription

        // add the bottom border to the view
        let border = CALayer()
        let width = CGFloat(0.5)

        border.borderColor = UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0).CGColor
        border.frame = CGRect(
                x: 0,
                y: self.backgroundView.frame.size.height - width,
                width:  self.backgroundView.frame.size.width,
                height: self.backgroundView.frame.size.height)

        border.borderWidth = width

        self.backgroundView.layer.addSublayer(border)
        self.backgroundView.layer.masksToBounds = true

        self.calendarView.delegate = self
        self.calendarView.appearance.delegate = self
        self.menuView.delegate = self

        self.tableView.registerNib(
        UINib(nibName: "WorkoutLogSectionCell", bundle: nil),
                forCellReuseIdentifier: "WorkoutLogSectionCell")

        self.tableView.registerNib(
        UINib(nibName: "WorkoutLogCardCell", bundle: nil),
                forCellReuseIdentifier: "WorkoutLogCardCell")

        tableView.delegate = self
        tableView.dataSource = self
    }

    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
    
    func toggleCurrentDayView(sender: UIBarButtonItem) {
        self.calendarView.toggleCurrentDayView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.showOrHideCardViewForDate(date!)

        self.calendarView.contentController.refreshPresentedMonth()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let weekContentViewController = self.calendarView.contentController as! CVCalendarWeekContentViewController

            for (_, weekView) in weekContentViewController.weekViews {
                for dayView in weekView.dayViews {
                    dayView.setDeselectedWithClearing(true)
                    dayView.selectionView = nil
                }
            }

            self.calendarView.validated = false
        }

        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let weekContentViewController = self.calendarView.contentController as! CVCalendarWeekContentViewController

            for (_, weekView) in weekContentViewController.weekViews {
                for dayView in weekView.dayViews {
                    let order = NSCalendar.currentCalendar().compareDate(date!, toDate: dayView.date.date, toUnitGranularity: .Day)

                    if (order == .OrderedSame) {
                        dayView.setSelectedWithType(.Single)
                    }
                }
            }
        }
    }

    func showOrHideCardViewForDate(date: NSDate) {
        self.date = date

        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(date)
        if (routines.count > 0) {
            self.routines = routines
            self.tableView?.backgroundView = nil
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))

            label.text = "When you log a workout, you'll see it here."
            label.font = UIFont(name: "Helvetica Neue", size: 15)
            label.textAlignment = .Center
            label.sizeToFit()

            self.routines = nil
            self.tableView?.backgroundView = label
        }

        self.tableView.reloadData()
    }

    func didSelectDayView(dayView: DayView, animationDidFinish: Bool) {
        self.showOrHideCardViewForDate(dayView.date.date)
    }

    func presentedDateUpdated(date: CVDate) {
        self.navigationItem.title = date.commonDescription
    }

    func presentationMode() -> CalendarMode {
        return .WeekView
    }

    func firstWeekday() -> Weekday {
        return .Monday
    }

    func shouldShowWeekdaysOut() -> Bool {
        return false
    }

    func shouldAnimateResizing() -> Bool {
        return false
    }

    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool {
        return false
    }

    func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool {
        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(dayView.date.date)

        return (routines.count > 0)
    }

    func dotMarker(colorOnDayView dayView: DayView) -> [UIColor] {
        return [UIColor.whiteColor()]
    }

    func dayLabelWeekdayOutTextColor() -> UIColor {
        return UIColor.whiteColor()
    }

    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor(red:0, green:0.27, blue:0.24, alpha:1)
    }

    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }

    func dayLabelPresentWeekdaySelectedBackgroundAlpha() -> CGFloat {
        return 1
    }

    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return UIColor.blackColor()
    }

    func dayLabelPresentWeekdayTextColor() -> UIColor {
        return UIColor.blackColor()
    }

    func dayOfWeekTextColor() -> UIColor {
        return UIColor(red:0, green: 0.27, blue: 0.24, alpha: 1)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = self.routines {
            return 1
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let routines = self.routines {
            return routines.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(
        "WorkoutLogSectionCell") as! WorkoutLogSectionCell

        cell.title.text = "Workout Log"

        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)
        cell.contentView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)

        return cell

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
        "WorkoutLogCardCell",
                forIndexPath: indexPath) as! WorkoutLogCardCell

        if let routines = self.routines {
            let repositoryRoutine = routines[indexPath.row]

            cell.parentController = self
            cell.date = date

            cell.title.text = repositoryRoutine.title
            cell.subtitle.text = repositoryRoutine.subtitle

            cell.repositoryRoutine = repositoryRoutine
        }

        return cell
    }
}