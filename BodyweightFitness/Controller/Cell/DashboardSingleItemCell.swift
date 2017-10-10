import UIKit

class DashboardSingleItemCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: ActionView!
    @IBOutlet weak var button: UIButton!
    
    var dashboardViewController: DashboardViewController?
    
    fileprivate var _exercise: Exercise? = nil
    var exercise: Exercise? {
        get {
            return _exercise
        }
        
        set {
            self._exercise = newValue
            
            if let exercise = newValue {
                if (exercise.isTimed()) {
                    self.button.setImage(UIImage(named: "timed"), for: UIControlState())
                } else {
                    self.button.setImage(UIImage(named: "weighted"), for: UIControlState())
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onClick(_ sender: UITapGestureRecognizer) {
        self.dashboardViewController?.dismissWithExercise(exercise!)
    }
}
