import Foundation
import UIKit

class WorkoutLogViewController: UIViewController {
    var date: Date?
    var repositoryRoutine: RepositoryRoutine?
    
    var pageMenu: CAPSPageMenu?
    var controllerArray: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        
        if let routine = repositoryRoutine {
            self.navigationItem.title = routine.startTime.commonDescription
        }
        
        let generalViewController: ProgressGeneralViewController = ProgressGeneralViewController(
            nibName: "ProgressGeneralViewController",
            bundle: nil)
        
        generalViewController.parentController = self.navigationController
        generalViewController.title = "General"
        generalViewController.date = date
        generalViewController.repositoryRoutine = self.repositoryRoutine
        
        controllerArray.append(generalViewController)
        
        if let routine = repositoryRoutine {
            for category in routine.categories {
                let viewController: ProgressPageViewController = ProgressPageViewController(
                    nibName: "ProgressPageViewController",
                    bundle: nil)
                
                viewController.parentController = self.navigationController
                viewController.title = category.title
                viewController.category = category
                
                controllerArray.append(viewController)
            }
        }
        
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(
                UIColor(red:0, green:0.59, blue:0.53, alpha:1)
            ),
            .viewBackgroundColor(
                UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.00)
            ),
            .selectionIndicatorColor(
                UIColor(red:0.02, green:0.21, blue:0.18, alpha:1)
            ),
            .bottomMenuHairlineColor(
                UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)
            ),
            .selectedMenuItemLabelColor(
                UIColor(red:0, green:0.33, blue:0.29, alpha:1)
            ),
            .unselectedMenuItemLabelColor(
                UIColor(red:0, green:0.33, blue:0.29, alpha:1)
            ),
            .menuItemFont(
                UIFont(name: "HelveticaNeue", size: 13.0)!
            ),
            .selectionIndicatorHeight(2.0),
            .menuHeight(40.0),
            .menuItemWidth(90.0),
            .centerMenuItems(true)
        ]
        
        pageMenu = CAPSPageMenu(
            viewControllers: controllerArray,
            frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height),
            pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
}
