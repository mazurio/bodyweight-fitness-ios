import UIKit

class DashboardSingleItemViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: ActionView!
    
    var dashboardViewController: DashboardViewController?
    var exercise: Exercise?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.view.layer.cornerRadius = self.view.frame.size.width / 2
        self.view.clipsToBounds = true
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onClick:"))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onClick(sender: UITapGestureRecognizer) {
        self.dashboardViewController?.dismissWithExercise(exercise!)
    }
}
