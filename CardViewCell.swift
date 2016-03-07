import UIKit

class CardViewCell: UITableViewCell {
    var parentController: UIViewController?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var exercise: RepositoryExercise?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClickFullReport(sender: AnyObject) {
        if let parentController = self.parentController {
            let logWorkoutController = parentController.storyboard?.instantiateViewControllerWithIdentifier("LogWorkoutController") as! LogWorkoutController
            
            logWorkoutController.setRepositoryRoutine(
                exercise!,
                repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday()
            )
            
            logWorkoutController.parentController = parentController
            
            parentController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            parentController.modalPresentationStyle = .CurrentContext
            
            parentController.presentViewController(logWorkoutController, animated: true, completion: nil)
            
            parentController.dim(.In, alpha: 0.5, speed: 0.5)
        }
    }
}
