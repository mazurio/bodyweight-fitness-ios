import UIKit

class NavigationViewController: UIViewController {
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var bottomLeftLabel: UILabel!
    @IBOutlet var bottomRightLabel: UILabel!
    
    init() {
        super.init(nibName: "NavigationView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}