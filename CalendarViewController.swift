import Foundation
import UIKit
import RealmSwift

class CalendarViewController: UIViewController,
    CVCalendarViewDelegate,
    CVCalendarMenuViewDelegate,
    CVCalendarViewAppearanceDelegate,
    UITableViewDataSource,
    UITableViewDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet var tableView: UITableView!
    
    var date: NSDate?
    var routines: Results<RepositoryRoutine>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
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
        
        self.navigationItem.title = CVDate(date: NSDate()).commonDescription
        
        self.tableView.registerNib(
            UINib(nibName: "CalendarSectionViewCell", bundle: nil),
            forCellReuseIdentifier: "CalendarSectionViewCell")
        
        self.tableView.registerNib(
            UINib(nibName: "CalendarCardViewCell", bundle: nil),
            forCellReuseIdentifier: "CalendarCardViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showOrHideCardViewForDate(NSDate())

        self.calendarView.contentController.refreshPresentedMonth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.calendarView.commitCalendarViewUpdate()
        self.menuView.commitMenuViewUpdate()
    }
    
    func showOrHideCardViewForDate(date: NSDate) {
        self.date = date
        
        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(date)
        if (routines.count > 0) {
            self.routines = routines
        } else {
            // show message
            self.routines = nil
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
        if (indexPath.row == 0) {
            return 166
        }
        
        return 166
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "CalendarSectionViewCell") as! CalendarSectionViewCell
        
        cell.title.text = "Workout Log"
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "CalendarCardViewCell",
            forIndexPath: indexPath) as! CalendarCardViewCell
        
        if let routines = self.routines {
            let repositoryRoutine = routines[indexPath.row]
            
            cell.parentController = self
            cell.date = date
            
            cell.title.text = "Bodyweight Fitness"
            cell.subtitle.text = "Beginner Routine"
            
            cell.repositoryRoutine = repositoryRoutine
        }

        return cell
    }

    @IBAction func onClickNavigationItem(sender: AnyObject) {
        self.sideNavigationViewController?.toggle()
    }
    
    
    @IBAction func onClickNavigationCalendar(sender: AnyObject) {
        self.calendarView.toggleCurrentDayView()
    }
}
