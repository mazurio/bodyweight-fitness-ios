import UIKit
import MessageUI

func getWeightUnit() -> String {
    if PersistenceManager.getWeightUnit() == "lbs" {
        return "lbs"
    } else {
        return "kg"
    }
}

class WorkoutLogCardCell: UITableViewCell, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var progressRate: UILabel!
    
    var parentController: UIViewController?
    var date: Date?
    var repositoryRoutine: RepositoryRoutine?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClickView(_ sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "WorkoutLog", bundle: Bundle.main)
        
        let p = storyboard.instantiateViewController(
            withIdentifier: "WorkoutLogViewController"
        ) as! WorkoutLogViewController
        
        p.date = date
        p.repositoryRoutine = repositoryRoutine
        p.hidesBottomBarWhenPushed = true
        
        self.parentController?.navigationController?.pushViewController(p, animated: true)
    }
    
    @IBAction func onClickExport(_ sender: AnyObject) {
        let mailString = NSMutableString()
        
        if let routine = repositoryRoutine {
            let helper = RepositoryRoutineHelper(repositoryRoutine: routine)
            
            let date = helper.getDate()
            let startTime = helper.getStartTime()
            let lastUpdatedTime = helper.getLastUpdatedTime()
            
            let exercises = repositoryRoutine?.exercises.filter { (exercise) in
                exercise.visible == true
            }
            
            mailString.append("Date, Start Time, End Time, Workout Length, Routine, Exercise, Set Order, Weight, Weight Units, Reps, Minutes, Seconds\n")
            
            for exercise in exercises! {
                let title = exercise.title
                let weightValue = getWeightUnit()
                var index = 1
                
                for set in exercise.sets {
                    let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)
                    
                    mailString.append(String(
                        format: "%@,%@,%@,%@,%@,%@,%d,%f,%@,%d,%d,%d\n",
                        date,
                        startTime,
                        lastUpdatedTime,
                        "1h 10m",
                        "\(routine.title) - \(routine.subtitle)",
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
            let emailTitle = "\(routine.title) workout for \(helper.getStartTime(true))"
            
            content.append("Hello,\nThe following is your workout in Text/HTML format (CSV attached).")
            
            content.append("\n\nWorkout on \(helper.getStartTime(true)).")
            content.append("\nLast Updated at \(helper.getLastUpdatedTime())")
            content.append("\nWorkout length: \(helper.getWorkoutLength())")
            
            content.append("\n\n\(routine.title)\n\(routine.subtitle)")
            
            let weightUnit = getWeightUnit()
            
            if let exercises = exercises {
                for exercise in exercises {
                    content.append("\n\n\(exercise.title)")
                    
                    var index = 1
                    for set in exercise.sets {
                        let (_, minutes, seconds) = secondsToHoursMinutesSeconds(set.seconds)
                        
                        content.append("\nSet \(index)")
                        
                        if (set.isTimed) {
                            if minutes > 0 {
                                content.append(", Minutes: \(minutes)")
                            }
                            
                            content.append(", Seconds: \(seconds)")
                        } else {
                            content.append(", Reps: \(set.reps)")
                            
                            if set.weight > 0 {
                                content.append(", Weight: \(set.weight) \(weightUnit)")
                            }
                        }
                        
                        index += 1
                    }
                }
                
            }
            
            let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
            if let data = data {
                if !MFMailComposeViewController.canSendMail() {
                    print("Mail services are not available")
                    return
                }
                
                let emailViewController = configuredMailComposeViewController(data, subject: emailTitle, messageBody: content as String)
                
                if MFMailComposeViewController.canSendMail() {
                    self.parentController?.present(emailViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func onClickRemove(_ sender: AnyObject) {
        let alertController = UIAlertController(
            title: "Remove Workout",
            message: "Are you sure you want to remove this workout?",
            preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.cancel,
            handler: nil))
        
        alertController.addAction(UIAlertAction(
            title: "Remove",
            style: UIAlertActionStyle.destructive,
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

                RoutineStream.sharedInstance.setRepository()
        }))
        
        self.parentController?.present(alertController, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController(_ data: Data, subject: String, messageBody: String) -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        
        emailController.mailComposeDelegate = self
        emailController.setSubject(subject)
        emailController.setMessageBody(messageBody, isHTML: false)
        emailController.addAttachmentData(data, mimeType: "text/csv", fileName: "Workout.csv")
        
        return emailController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
