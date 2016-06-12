import Foundation
import UIKit

class HomeViewController: UIViewController {
    init() {
        super.init(nibName: "HomeView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        let menuItem = UIBarButtonItem(
            image: UIImage(named: "menu"),
            landscapeImagePhone: nil,
            style: .Plain,
            target: self,
            action: #selector(dismiss))

        self.navigationItem.leftBarButtonItem = menuItem
        self.navigationItem.title = "Home"
    }
    
    func dismiss(sender: UIBarButtonItem) {
        self.sideNavigationController?.toggleLeftView()
    }
}