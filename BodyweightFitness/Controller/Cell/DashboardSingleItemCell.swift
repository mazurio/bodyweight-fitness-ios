import UIKit

class DashboardSingleItemCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: ActionView!
    @IBOutlet weak var button: UIButton!
    
    var dashboardViewController: DashboardViewController?
    
    private var _exercise: Exercise? = nil
    var exercise: Exercise? {
        get {
            return _exercise
        }
        
        set {
            self._exercise = newValue
            
            if let exercise = newValue {
                if (exercise.isTimed()) {
                    self.button.setImage(UIImage(named: "timed"), forState: .Normal)
                } else {
                    self.button.setImage(UIImage(named: "weighted"), forState: .Normal)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.view.layer.cornerRadius = self.view.frame.size.width / 2
        self.view.clipsToBounds = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DashboardSingleItemCell.onClick(_:))))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onClick(sender: UITapGestureRecognizer) {
        self.dashboardViewController?.dismissWithExercise(exercise!)
    }
}
