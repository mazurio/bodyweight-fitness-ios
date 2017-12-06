import UIKit

class ProgressCardCell: UITableViewCell {
    var parentController: UIViewController?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    var current: RepositoryExercise?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onClickFullReport(_ sender: AnyObject) {
        let logWorkoutController = LogWorkoutController()
        
        logWorkoutController.parentController = self.parentController
        logWorkoutController.setRepositoryRoutine(repositoryExercise: current!, repositoryRoutine: RepositoryStream.sharedInstance.getRepositoryRoutineForToday())
        
        logWorkoutController.modalTransitionStyle = .coverVertical
        logWorkoutController.modalPresentationStyle = .custom
        
        self.parentController?.dim(.in, alpha: 0.5, speed: 0.5)
        self.parentController?.present(logWorkoutController, animated: true, completion: nil)
    }
}
