import UIKit
import MessageUI

func getWeightUnit() -> String {
    if PersistenceManager.getWeightUnit() == "lbs" {
        return "lbs"
    } else {
        return "kg"
    }
}

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
        
        let date = repositoryRoutine!.getDate()
        let startTime = repositoryRoutine!.getStartTime()
        let lastUpdatedTime = repositoryRoutine!.getLastUpdatedTime()
        
        let exercises = repositoryRoutine?.exercises.filter { (exercise) in
            exercise.visible == true
        }
        
        mailString.appendString("Date, Start Time, End Time, Workout Length, Routine, Exercise, Set Order, Weight, Weight Units, Reps, Minutes, Seconds\n")
        
        for exercise in exercises! {
            let title = exercise.title
            let weightValue = getWeightUnit()
            var index = 1
            
            for set in exercise.sets {
                let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)
                
                mailString.appendString(String(
                    format: "%@,%@,%@,%@,%@,%@,%d,%f,%@,%d,%d,%d\n",
                    date,
                    startTime,
                    lastUpdatedTime,
                    "1h 10m",
                    "Bodyweight Fitness - Recommended Routine",
                    title,
                    index,
                    set.weight,
                    weightValue,
                    set.reps,
                    minutes,
                    seconds))
                
                index += 1
            }
        }
        
        let content = NSMutableString()
        
        content.appendString("Hello,\nThe following is your workout in Text/HTML format (CSV attached).")
        
        var emailTitle: String = "Bodyweight Fitness Workout"
        
        if let routine = repositoryRoutine {
            emailTitle = "Bodyweight Fitness workout for \(routine.getStartTime(true))"
            
            content.appendString("\n\nWorkout on \(routine.getStartTime(true)).")
            content.appendString("\nLast Updated at \(routine.getLastUpdatedTime())")
            content.appendString("\nWorkout length: --")
        }

        content.appendString("\n\nBodyweight Fitness\nRecommended Routine")
        
        let weightUnit = getWeightUnit()
        
        if let exercises = exercises {
            for exercise in exercises {
                content.appendString("\n\n\(exercise.title)")
                
                var index = 1
                for set in exercise.sets {
                    let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)
                    
                    content.appendString("\nSet \(index)")
                    
                    if (set.isTimed) {
                        content.appendString("\nMinutes: \(minutes)")
                        content.appendString("\nSeconds: \(seconds)")
                    } else {
                        content.appendString("\nReps: \(set.reps)")
                        content.appendString("\nWeight: \(set.weight) \(weightUnit)")
                    }
                    
                    index += 1
                }
            }

        }
        
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if let c = data {
            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                return
            }
            
            let emailViewController = configuredMailComposeViewController(c, subject: emailTitle, messageBody: content as String)
            
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
    
    func configuredMailComposeViewController(data: NSData, subject: String, messageBody: String) -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        
        emailController.mailComposeDelegate = self
        emailController.setSubject(subject)
        emailController.setMessageBody(messageBody, isHTML: false)
        emailController.addAttachmentData(data, mimeType: "text/csv", fileName: "Workout.csv")
        
        return emailController
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
