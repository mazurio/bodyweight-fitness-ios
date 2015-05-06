import UIKit

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class CenterViewController: UIViewController {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var creatorLabel: UILabel!
  
    var delegate: CenterViewControllerDelegate?
    
    @IBAction func kittiesTapped(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
    }
  
    @IBAction func puppiesTapped(sender: AnyObject) {
  
    }
}