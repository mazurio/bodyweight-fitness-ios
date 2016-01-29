import Foundation
import UIKit
import SwiftCharts

class ProgressGeneralViewController: UIViewController {
    var parentController: UIViewController?
    
    var date: NSDate?
    var repositoryRoutine: RepositoryRoutine?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setRoutine(date: NSDate, repositoryRoutine: RepositoryRoutine) {
        self.date = date
        self.repositoryRoutine = repositoryRoutine
    }
}
