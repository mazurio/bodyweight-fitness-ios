import UIKit

class SideViewHeaderCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        _ = RoutineStream.sharedInstance.routineObservable().subscribe(onNext: {
            self.title.text = $0.title
            self.subtitle.text = $0.subtitle
        })
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
