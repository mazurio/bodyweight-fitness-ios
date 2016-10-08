import UIKit
import RealmSwift

import UIKit

extension NSDate {
    public var globalDescription: String {
        get {
            let month = dateFormattedStringWithFormat("MMMM", fromDate: self)
            let year = dateFormattedStringWithFormat("YYYY", fromDate: self)

            return "\(month), \(year)"
        }
    }

    public var commonDescription: String {
        get {
            let day = dateFormattedStringWithFormat("dd", fromDate: self)
            let month = dateFormattedStringWithFormat("MMMM", fromDate: self)
            let year = dateFormattedStringWithFormat("YYYY", fromDate: self)

            return "\(day) \(month), \(year)"
        }
    }

    func dateFormattedStringWithFormat(format: String, fromDate date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }

    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false

        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }

        //Return Result
        return isGreater
    }

    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false

        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }

        //Return Result
        return isLess
    }

    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false

        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }

        //Return Result
        return isEqualTo
    }
}

class CellView: JTAppleDayCellView {
    @IBInspectable var todayColor: UIColor!// = UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.3)
    @IBInspectable var normalDayColor: UIColor! //UIColor(white: 0.0, alpha: 0.1)

    @IBOutlet var selectedView: AnimationView!
    @IBOutlet var dot: UIView!
    @IBOutlet var dayLabel: UILabel!

    lazy var todayDate : String = {
        [weak self] in
        let aString = self!.c.stringFromDate(NSDate())
        return aString
    }()

    lazy var c : NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd"

        return f
    }()

    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(cellState.date)

        if (routines.count > 0) {
            self.dot.hidden = false
        } else {
            self.dot.hidden = true
        }

        self.dot.layer.cornerRadius = self.dot.frame.width / 2
        self.selectedView.layer.cornerRadius = self.selectedView.frame.width / 2

        // Setup Cell text
        self.dayLabel.text = cellState.text

        // Mark todays date
        if (c.stringFromDate(date) == todayDate) {
            selectedView.backgroundColor = UIColor.primaryDark()
        } else {
            selectedView.backgroundColor = UIColor.whiteColor()
        }

        configureTextColor(cellState)

        delayRunOnMainThread(0.0) {
            self.configureViewIntoBubbleView(cellState)
        }

        configureVisibility(cellState)
    }

    func configureVisibility(cellState: CellState) {
        self.hidden = false
    }

    func configureTextColor(cellState: CellState) {
        if cellState.isSelected {
            if (c.stringFromDate(cellState.date) == todayDate) {
                dayLabel.textColor = UIColor.whiteColor()
            } else {
                dayLabel.textColor = UIColor.blackColor()
            }
        } else if cellState.dateBelongsTo == .ThisMonth {
            dayLabel.textColor = UIColor.blackColor()
        } else {
            dayLabel.textColor = UIColor.primaryDark()
        }
    }

    func cellSelectionChanged(cellState: CellState) {
        if cellState.isSelected == true {
            if selectedView.hidden == true {
                configureViewIntoBubbleView(cellState)
                selectedView.animateWithBounceEffect(withCompletionHandler: nil)
            }
        } else {
            configureViewIntoBubbleView(cellState, animateDeselection: true)
        }
    }

    private func configureViewIntoBubbleView(cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {
            self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
            self.selectedView.hidden = false
            self.dot.hidden = true

            self.configureTextColor(cellState)
        } else {
            if animateDeselection {
                self.configureTextColor(cellState)

                if self.selectedView.hidden == false {
                    self.selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
                        self.selectedView.hidden = true
                        self.selectedView.alpha = 1
                    })
                }
            } else {
                self.selectedView.hidden = true
            }

            let routines = RepositoryStream.sharedInstance.getRoutinesForDate(cellState.date)

            if (routines.count > 0) {
                self.dot.hidden = false
            } else {
                self.dot.hidden = true
            }
        }
    }
}

class AnimationClass {

    class func BounceEffect() -> (UIView, Bool -> Void) -> () {
        return {
            view, completion in
            view.transform = CGAffineTransformMakeScale(0.5, 0.5)

            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                view.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: completion)
        }
    }

    class func FadeOutEffect() -> (UIView, Bool -> Void) -> () {
        return {
            view, completion in

            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [], animations: {
                view.alpha = 0
            },
                    completion: completion)
        }
    }

    private class func get3DTransformation(angle: Double) -> CATransform3D {

        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        transform = CATransform3DRotate(transform, CGFloat(angle * M_PI / 180.0), 0, 1, 0.0)

        return transform
    }

    class func flipAnimation(view: UIView, completion: (() -> Void)?) {

        let angle = 180.0
        view.layer.transform = get3DTransformation(angle)

        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .TransitionNone, animations: { () -> Void in
            view.layer.transform = CATransform3DIdentity
        }) { (finished) -> Void in
            completion?()
        }
    }
}

class AnimationView: UIView {

    func animateWithFlipEffect(withCompletionHandler completionHandler:(()->Void)?) {
        AnimationClass.flipAnimation(self, completion: completionHandler)
    }
    func animateWithBounceEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.BounceEffect()
        viewAnimation(self){ _ in
            completionHandler?()
        }
    }
    func animateWithFadeEffect(withCompletionHandler completionHandler:(()->Void)?) {
        let viewAnimation = AnimationClass.FadeOutEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
}

class WorkoutLogViewController: UIViewController,
        UITableViewDataSource,
        UITableViewDelegate,
        JTAppleCalendarViewDataSource,
        JTAppleCalendarViewDelegate {

    var numberOfRows = 1

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet var tableView: UITableView!

    var date: NSDate = NSDate()
    var routines: Results<RepositoryRoutine>?

    let formatter = NSDateFormatter()
    let testCalendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

    init() {
        super.init(nibName: "WorkoutLogView", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.setNavigationBar()

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

        self.tableView.registerNib(
                UINib(nibName: "WorkoutLogSectionCell", bundle: nil),
                forCellReuseIdentifier: "WorkoutLogSectionCell")

        self.tableView.registerNib(
                UINib(nibName: "WorkoutLogCardCell", bundle: nil),
                forCellReuseIdentifier: "WorkoutLogCardCell")

        tableView.delegate = self
        tableView.dataSource = self

        formatter.dateFormat = "yyyy MM dd"
        testCalendar.timeZone = NSTimeZone(abbreviation: "GMT")!

        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(fileName: "CellView")
        calendarView.direction = .Horizontal
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.allowsMultipleSelection = false
        calendarView.firstDayOfWeek = .Monday
        calendarView.scrollEnabled = true
        calendarView.scrollingMode = .StopAtEachCalendarFrameWidth
        calendarView.itemSize = nil
        calendarView.rangeSelectionWillBeUsed = false

        calendarView.reloadData()

        calendarView.scrollToDate(NSDate(), triggerScrollToDateDelegate: false, animateScroll: false) {
            self.calendarView.selectDates([NSDate()])
        }
    }
    
    func toggleCurrentDayView(sender: UIBarButtonItem) {
        self.calendarView.scrollToDate(NSDate(), animateScroll: false)
        self.calendarView.selectDates([NSDate()])
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tabBarController?.navigationItem.titleView = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "calendar"),
                landscapeImagePhone: nil,
                style: .Plain,
                target: self,
                action: #selector(toggleCurrentDayView))

        self.tabBarController?.title = date.commonDescription

        self.showOrHideCardViewForDate(date)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutLogSectionCell") as! WorkoutLogSectionCell

        cell.title.text = "Workout Log"

        cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)
        cell.contentView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)

        return cell

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutLogCardCell", forIndexPath: indexPath) as! WorkoutLogCardCell

        if let routines = self.routines {
            let repositoryRoutine = routines[indexPath.row]
            let completionRate = RepositoryRoutineHelper.getCompletionRate(repositoryRoutine)

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

    func configureCalendar(calendar: JTAppleCalendarView) -> (
            startDate: NSDate,
            endDate: NSDate,
            numberOfRows: Int,
            calendar: NSCalendar) {

        let firstDate = formatter.dateFromString("2015 01 01")
        let secondDate = NSDate()
        let aCalendar = NSCalendar.currentCalendar()

        return (startDate: firstDate!,
                endDate: secondDate,
                numberOfRows: numberOfRows,
                calendar: aCalendar)
    }

    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as? CellView)?.setupCellBeforeDisplay(cellState, date: date)
    }

    func calendar(calendar: JTAppleCalendarView, didDeselectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)
    }

    func calendar(calendar: JTAppleCalendarView, didSelectDate date: NSDate, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState)

        self.date = cellState.date
        self.tabBarController?.navigationItem.title = self.date.commonDescription

        showOrHideCardViewForDate(self.date)
    }

    func calendar(calendar: JTAppleCalendarView, isAboutToResetCell cell: JTAppleDayCellView) {
        (cell as? CellView)?.selectedView.hidden = true
    }

    func calendar(calendar: JTAppleCalendarView,
                  didScrollToDateSegmentStartingWithdate startDate: NSDate,
                  endingWithDate endDate: NSDate) {

        let todayDate = NSDate()

        if (todayDate.isGreaterThanDate(startDate) && todayDate.isLessThanDate(endDate)) {
            calendar.selectDates([todayDate])
        } else if (todayDate.isEqualToDate(startDate) || todayDate.isEqualToDate(endDate)) {
            calendar.selectDates([todayDate])
        } else {
            calendar.selectDates([startDate])
        }
    }
}
