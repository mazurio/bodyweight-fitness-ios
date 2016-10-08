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
        let logWorkoutController = LogWorkoutController()
        
        logWorkoutController.parentController = self.parentController
        logWorkoutController.setRepositoryRoutine(current!, repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
        
        logWorkoutController.modalTransitionStyle = .CoverVertical
        logWorkoutController.modalPresentationStyle = .Custom
        
        self.parentController?.dim(.In, alpha: 0.5, speed: 0.5)
        self.parentController?.presentViewController(logWorkoutController, animated: true, completion: nil)
    }
}
