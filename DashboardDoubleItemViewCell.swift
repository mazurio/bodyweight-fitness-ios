import UIKit

class DashboardDoubleItemViewCell: UITableViewCell {
    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var rightTitle: UILabel!
    
    @IBOutlet weak var leftView: ActionView!
    @IBOutlet weak var rightView: ActionView!
    
    var dashboardViewController: DashboardViewController?
    var leftExercise: Exercise?
    var rightExercise: Exercise?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.leftView.layer.cornerRadius = self.leftView.frame.size.width / 2
        self.leftView.clipsToBounds = true
        
        self.rightView.layer.cornerRadius = self.rightView.frame.size.width / 2
        self.rightView.clipsToBounds = true
        
        self.leftView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLeftClick:"))
        self.rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onRightClick:"))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onLeftClick(sender: UITapGestureRecognizer) {
        self.dashboardViewController?.dismissWithExercise(leftExercise!)
    }
    
    func onRightClick(sender: UITapGestureRecognizer) {
        self.dashboardViewController?.dismissWithExercise(rightExercise!)
    }
}
