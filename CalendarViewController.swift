import Foundation
import UIKit
import MessageUI

class CalendarViewController:
    UIViewController,
    CVCalendarViewDelegate,
    CVCalendarMenuViewDelegate,
    CVCalendarViewAppearanceDelegate,
    MFMailComposeViewControllerDelegate {
    
    var date: NSDate?
    var repositoryRoutine: RepositoryRoutine?
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cardViewLabel: UILabel!
    @IBOutlet weak var cardView: CardView!
    
    func configuredMailComposeViewController(data: NSData) -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        
        emailController.mailComposeDelegate = self
        emailController.setSubject("CSV File")
        emailController.setMessageBody("Bodyweight Fitness Summary for: ", isHTML: false)
        emailController.addAttachmentData(data, mimeType: "text/csv", fileName: "Workout.csv")
        
        return emailController
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            // Check the result or perform other tasks.
            
            // Dismiss the mail compose view controller.
            controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @IBAction func onClickViewAction(sender: AnyObject) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let progressViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProgressViewController") as! ProgressViewController
        
        progressViewController.setRoutine(self.date!, repositoryRoutine: self.repositoryRoutine!)
  
        self.showViewController(progressViewController, sender: nil)
    }
    
    @IBAction func onClickShareAction(sender: AnyObject) {
        let mailString = NSMutableString()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        let date = formatter.stringFromDate(repositoryRoutine!.startTime)
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .LongStyle
        
        let startTime = timeFormatter.stringFromDate(repositoryRoutine!.startTime)
        let endTime = timeFormatter.stringFromDate(repositoryRoutine!.lastUpdatedTime)
        
        let exercises = repositoryRoutine?.exercises.filter { (exercise) in
            exercise.visible == true
        }
        
        mailString.appendString("Date, Start Time, End Time, Workout Length, Routine, Exercise, Set Order, Weight, Weight Units, Reps, Minutes, Seconds\n")
        
        for exercise in exercises! {
            let title = exercise.title
            let weightValue: String = "kg"
            var index = 1
            
            for set in exercise.sets {
                let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)

                mailString.appendString(String(
                    format: "%@,%@,%@,%@,%@,%@,%d,%f,%@,%d,%d,%d\n",
                    date,
                    startTime,
                    endTime,
                    "1h 10m",
                    "Bodyweight Fitness - Beginner Routine",
                    title,
                    index,
                    set.weight,
                    weightValue,
                    set.reps,
                    minutes,
                    seconds))
                
                index++
            }
            
        }
        
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if let content = data {
            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                return
            }
            
            let emailViewController = configuredMailComposeViewController(content)
            
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(emailViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onClickRemoveAction(sender: AnyObject) {
        let alertController = UIAlertController(
            title: "Remove Workout",
            message: "Are you sure you want to remove this workout?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler: nil))
        
        alertController.addAction(UIAlertAction(
            title: "Remove",
            style: UIAlertActionStyle.Destructive,
            handler: { (action: UIAlertAction!) in
                let realm = RepositoryStream.sharedInstance.getRealm()
                try! realm.write {
                    realm.delete(self.repositoryRoutine!)
                }
                
                self.messageLabel.hidden = false
                
                self.cardViewLabel.hidden = true
                self.cardView.hidden = true
            }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onClickNavigationItem(sender: AnyObject) {
        self.sideNavigationViewController?.toggle()
    }
    
    
    @IBAction func onClickNavigationCalendar(sender: AnyObject) {
        self.calendarView.toggleCurrentDayView()
    }
    
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
        if let repositoryRoutine = RepositoryStream.sharedInstance.getRepositoryRoutineForDate(date) {
            self.date = date
            self.repositoryRoutine = repositoryRoutine
            
            self.messageLabel.hidden = true
            
            self.cardViewLabel.hidden = false
            self.cardView.hidden = false
        } else {
            self.messageLabel.hidden = false
            
            self.cardViewLabel.hidden = true
            self.cardView.hidden = true
        }

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
    
//    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
//        if let _ = RepositoryStream.sharedInstance.getRepositoryRoutineForDate(dayView.date.date) {
//            return true
//        } else {
//            return false
//        }
//
//        return false
//    }
//
//    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
//        return [UIColor.whiteColor()]
//    }
//
//    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
//        return true
//    }
//
//    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
//        return 13
//    }
    
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
        return UIColor(red:0, green:0.27, blue:0.24, alpha:1)
    }
}
