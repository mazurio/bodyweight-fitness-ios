import UIKit

class ProgressCardCell: UITableViewCell {
    var parentController: UIViewController?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var current: RepositoryExercise?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClickFullReport(sender: AnyObject) {
        if let parentController = self.parentController {
            let logWorkoutController = LogWorkoutController()
            
            logWorkoutController.parentController = parentController
            logWorkoutController.setRepositoryRoutine(current!, repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
            
            logWorkoutController.modalTransitionStyle = .CoverVertical
            logWorkoutController.modalPresentationStyle = .Custom
            
            parentController.dim(.In, alpha: 0.5, speed: 0.5)
            parentController.presentViewController(logWorkoutController, animated: true, completion: nil)
        }
    }
}
