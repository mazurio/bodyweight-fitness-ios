import UIKit

enum Direction { case `in`, out }

extension UIView {
    public func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

extension UIColor {
    class func primaryDark() -> UIColor {
        return UIColor(red:0.00, green:0.27, blue:0.24, alpha:1.00)
    }
    
    class func primary() -> UIColor {
        return UIColor(red:0.00, green:0.59, blue:0.53, alpha:1.00)
    }
}

extension UIViewController {
    func setNavigationBar() {
        let titleDict: NSDictionary = [
            NSForegroundColorAttributeName: UIColor(red:0, green:0.27, blue:0.24, alpha:1)
        ]
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: UIBarMetrics.default
        )
    }
}

extension UIViewController {
    func alpha(_ direction: Direction, color: UIColor = UIColor.black, alpha: CGFloat = 0.5, speed: Double = 0.5) {
        switch direction {
        case .in:
            let frame = CGRect(x: 0, y: -20, width: view.frame.width, height: view.frame.height + 20)
            let dimView = UIView(frame: frame)
            
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            
            view.addSubview(dimView)
            
            dimView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "|[dimView]|",
                options: [],
                metrics: nil,
                views: ["dimView": dimView]))
            
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[dimView]|",
                options: [],
                metrics: nil,
                views: ["dimView": dimView]))
            
            UIView.animate(withDuration: speed, animations: { () -> Void in
                dimView.alpha = alpha
            }) 
            
        case .out:
            UIView.animate(withDuration: speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha
                }, completion: { (complete) -> Void in
                    self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
    
    func dim(_ direction: Direction, color: UIColor = UIColor.black, alpha: CGFloat = 0.0, speed: Double = 0.0) {
        switch direction {
        case .in:
            let dimView = UIView(frame: view.frame)
            
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            
            view.addSubview(dimView)
            
            dimView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "|[dimView]|",
                options: [],
                metrics: nil,
                views: ["dimView": dimView]))
            
            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[dimView]|",
                options: [],
                metrics: nil,
                views: ["dimView": dimView]))
            
            UIView.animate(withDuration: speed, animations: { () -> Void in
                dimView.alpha = alpha
            }) 
            
        case .out:
            UIView.animate(withDuration: speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha
                }, completion: { (complete) -> Void in
                    self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
}
