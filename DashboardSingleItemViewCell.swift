import UIKit

class DashboardSingleItemViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var view: ActionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.view.layer.cornerRadius = self.view.frame.size.width / 2
        self.view.clipsToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
