import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}

let centerPanelExpandedOffset: CGFloat = 60

class ContainerViewController: UIViewController {
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    var currentState: SlideOutState = SlideOutState.BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != SlideOutState.BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var leftViewController: SidePanelViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
}

extension ContainerViewController: CenterViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func toggleRightPanel() {}
    
    func addLeftPanelViewController() {
        if leftViewController == nil {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController!.animals = Animal.allCats()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func addRightPanelViewController() {}
    
    func animateLeftPanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .BothCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateRightPanel(#shouldExpand: Bool) {}
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == .BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                } else {
                    addRightPanelViewController()
                }
                
                showShadowForCenterViewController(true)
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if(leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
}

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
  
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? SidePanelViewController
    }
  
    class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
    }
}