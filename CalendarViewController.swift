import Foundation
import UIKit

class CalendarViewController:
    UIViewController,
    CVCalendarViewDelegate,
    CVCalendarMenuViewDelegate,
    CVCalendarViewAppearanceDelegate {
    
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func onClickNavigationItem(sender: AnyObject) {
        sideNavigationViewController?.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleDict: NSDictionary = [
            NSForegroundColorAttributeName: UIColor(red:0, green:0.27, blue:0.24, alpha:1)
        ]
    
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        self.navigationController!.navigationBar.translucent = true
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.setBackgroundImage(
            UIImage(),
            forBarMetrics: UIBarMetrics.Default
        )
        
        calendarView.delegate = self
        calendarView.appearance.delegate = self
        
        menuView.delegate = self
        
        navigationItem.title = CVDate(date: NSDate()).commonDescription
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
    
    func presentedDateUpdated(date: CVDate) {
        navigationItem.title = date.commonDescription
    }
    
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func shouldAnimateResizing() -> Bool {
        return true
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor(red:0, green:0.27, blue:0.24, alpha:1)
    }
    
    //
    // Active selected day.
    //
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
    
    //
    // MenuView
    //
    func dayOfWeekTextColor() -> UIColor {
        return UIColor(red:0, green:0.27, blue:0.24, alpha:1)
    }
}
