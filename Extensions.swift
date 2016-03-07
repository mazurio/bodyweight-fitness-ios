import UIKit

enum Direction { case In, Out }

extension UIViewController {
    func setNavigationBar() {
        let titleDict: NSDictionary = [
            NSForegroundColorAttributeName: UIColor(red:0, green:0.27, blue:0.24, alpha:1)
        ]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            forBarMetrics: UIBarMetrics.Default
        )
    }
}

extension UIViewController {
    func dim(direction: Direction, color: UIColor = UIColor.blackColor(), alpha: CGFloat = 0.0, speed: Double = 0.0) {
        switch direction {
        case .In:
            let dimView = UIView(frame: view.frame)
            
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            
            view.addSubview(dimView)
            
            dimView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                "|[dimView]|",
                options: [],
                metrics: nil,
                views: ["dimView": dimView]))
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[dimView]|",
                options: [],
                metrics: nil,
                views: ["dimView": dimView]))
            
            UIView.animateWithDuration(speed) { () -> Void in
                dimView.alpha = alpha
            }
            
        case .Out:
            UIView.animateWithDuration(speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha ?? 0
                }, completion: { (complete) -> Void in
                    self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
}