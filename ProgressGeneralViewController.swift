import Foundation
import UIKit
import SwiftCharts

class ProgressGeneralViewController: UIViewController {
    @IBOutlet var startTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var workoutLength: UILabel!
    
    var parentController: UIViewController?
    
    var date: NSDate?
    var repositoryRoutine: RepositoryRoutine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let routine = self.repositoryRoutine {
            self.startTime.text = routine.getStartTime()
            self.endTime.text = routine.getLastUpdatedTime()
            self.workoutLength.text = routine.getWorkoutLength()
            
            // If numberOfExercises == numberOfExercisesCompleted (100% progress) then:
            // Change label to End Time
        } else {
            self.startTime.text = "--"
            self.endTime.text = "--"
            self.workoutLength.text = "--"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
