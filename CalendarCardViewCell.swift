import UIKit
import MessageUI

class CalendarCardViewCell: UITableViewCell, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var parentController: UIViewController?
    var date: NSDate?
    var repositoryRoutine: RepositoryRoutine?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClickView(sender: AnyObject) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        
        self.parentController?.navigationItem.backBarButtonItem = backItem
        
        let progressViewController = self.parentController?.storyboard!.instantiateViewControllerWithIdentifier("ProgressViewController") as! ProgressViewController
        
        progressViewController.setRoutine(self.date!, repositoryRoutine: self.repositoryRoutine!)
        
        self.parentController?.showViewController(progressViewController, sender: nil)
    }
    
    @IBAction func onClickExport(sender: AnyObject) {
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
                    "Bodyweight Fitness - Recommended Routine",
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
                self.parentController?.presentViewController(emailViewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onClickRemove(sender: AnyObject) {
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
                
                if let parent = self.parentController as? CalendarViewController {
                    if let date = self.date {
                        parent.showOrHideCardViewForDate(date)
                    }
                }
        }))
        
        self.parentController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
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
}
