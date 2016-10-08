import UIKit
import PageMenuFramework

class ProgressViewController: UIViewController {
    var date: NSDate?
    var repositoryRoutine: RepositoryRoutine?
    var pageMenu: CAPSPageMenu?
    var controllerArray: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNavigationBar()
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.primaryDark()

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
            .ScrollMenuBackgroundColor(
                UIColor(red:0, green:0.59, blue:0.53, alpha:1)
            ),
            .ViewBackgroundColor(
                UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.00)
            ),
            .SelectionIndicatorColor(
                UIColor(red:0.02, green:0.21, blue:0.18, alpha:1)
            ),
            .BottomMenuHairlineColor(
                UIColor(red: 70.0/255.0, green: 70.0/255.0, blue: 80.0/255.0, alpha: 1.0)
            ),
            .SelectedMenuItemLabelColor(
                UIColor(red:0, green:0.33, blue:0.29, alpha:1)
            ),
            .UnselectedMenuItemLabelColor(
                UIColor(red:0, green:0.33, blue:0.29, alpha:1)
            ),
            .MenuItemFont(
                UIFont(name: "HelveticaNeue", size: 13.0)!
            ),
            .SelectionIndicatorHeight(2.0),
            .MenuHeight(40.0),
            .MenuItemWidth(90.0),
            .CenterMenuItems(true)
        ]
        
        pageMenu = CAPSPageMenu(
            viewControllers: controllerArray,
            frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height),
            pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
    
    func setRoutine(date: NSDate, repositoryRoutine: RepositoryRoutine) {
        self.date = date
        self.repositoryRoutine = repositoryRoutine
    }
}
