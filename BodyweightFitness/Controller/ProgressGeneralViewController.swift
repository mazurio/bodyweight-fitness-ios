import Foundation
import UIKit

import UIKit

class CircleGraphView: UIView {
    //
    // Range of 0.0 to 1.0
    //
    var endArc: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var arcWidth: CGFloat = 18.0
    var arcColor = UIColor(red:0.04, green:0.58, blue:0.58, alpha:1.00)
    var arcBackgroundColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    
    override func drawRect(rect: CGRect) {
        let fullCircle = 2.0 * CGFloat(M_PI)
        let start: CGFloat = -0.25 * fullCircle
        let end: CGFloat = endArc * fullCircle + start
        
        let centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
        
        var radius: CGFloat = 0.0
        
        if CGRectGetWidth(rect) > CGRectGetHeight(rect) {
            radius = (CGRectGetWidth(rect) - arcWidth) / 2.0
        } else {
            radius = (CGRectGetHeight(rect) - arcWidth) / 2.0
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context!, arcWidth)
        CGContextSetLineCap(context!, CGLineCap.Round)
        CGContextSetStrokeColorWithColor(context!, arcBackgroundColor.CGColor)
        CGContextAddArc(context!, centerPoint.x, centerPoint.y, radius, 0, fullCircle, 0)
        CGContextStrokePath(context!)
        CGContextSetStrokeColorWithColor(context!, arcColor.CGColor)
        CGContextSetLineWidth(context!, arcWidth * 0.8 )
        CGContextAddArc(context!, centerPoint.x, centerPoint.y, radius, start, end, 0)
        CGContextStrokePath(context!)
    }
}

class ProgressGeneralViewController: UIViewController {
    @IBOutlet var startTime: UILabel!
    
    @IBOutlet var endTime: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    
    @IBOutlet var workoutLength: UILabel!
    @IBOutlet var circleGraphView: CircleGraphView!
    
    @IBOutlet var progressValueLabel: UILabel!
    @IBOutlet var progressTextLabel: UILabel!
    
    var parentController: UIViewController?
    
    var date: NSDate?
    var repositoryRoutine: RepositoryRoutine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let routine = self.repositoryRoutine {
            let helper = RepositoryRoutineHelper(repositoryRoutine: routine)
            
            self.startTime.text = helper.getStartTime()
            self.endTime.text = helper.getLastUpdatedTime()
            self.workoutLength.text = helper.getWorkoutLength()
            
            if helper.isCompleted() {
                self.endTimeLabel.text = "End Time"
                self.progressTextLabel.text = "Congratulations!"
                self.progressValueLabel.text = "100%"
            } else {
                self.endTimeLabel.text = "Last Updated Time"
                
                if helper.exercisesLeft() == 1 {
                    self.progressTextLabel.text = "1 exercise to go"
                } else {
                    self.progressTextLabel.text = "\(helper.exercisesLeft()) exercises to go"
                }
                
                let onePercent: Double = 1 / Double(helper.totalExercises()) * 100
                let progress: Int = Int(Double(helper.completedExercises()) * onePercent)
                
                self.progressValueLabel.text = "\(progress)%"
            }
            
            self.circleGraphView.endArc = 0.0476 * CGFloat(helper.completedExercises())
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
