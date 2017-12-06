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
        
        let generalViewController = WorkoutLogGeneralViewController()
        generalViewController.title = "General"
        generalViewController.repositoryRoutine = repositoryRoutine
        controllerArray.append(generalViewController)
        
        if let repositoryRoutine = repositoryRoutine {
            for repositoryCategory in repositoryRoutine.categories {
                let categoryViewController = WorkoutLogCategoryViewController()
                categoryViewController.title = repositoryCategory.title
                categoryViewController.repositoryRoutine = repositoryRoutine
                categoryViewController.repositoryCategory = repositoryCategory
                controllerArray.append(categoryViewController)
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
                UIColor.primary()
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
            pageMenuOptions: parameters
        )

        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        self.pageMenu!.didMove(toParentViewController: self)
    }
}
