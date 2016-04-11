import UIKit
import StoreKit

class SupportDeveloperViewController: UIViewController {
    init() {
        super.init(nibName: "SupportDeveloperView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let menuItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss))
        
        menuItem.tintColor = UIColor.primaryDark()
        
        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.title = "Support Developer"
        
        self.navigationController?.navigationBar.barTintColor = UIColor.primary()
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
}