import UIKit
import JTAppleCalendar

class CellView: JTAppleCell {
    @IBInspectable var todayColor: UIColor!// = UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.3)
    @IBInspectable var normalDayColor: UIColor! //UIColor(white: 0.0, alpha: 0.1)
    
    @IBOutlet var selectedView: AnimationView!
    @IBOutlet var dot: UIView!
    @IBOutlet var dayLabel: UILabel!
    
    lazy var todayDate : String = {
        [weak self] in
        let aString = self!.c.string(from: Date())
        return aString
        }()
    
    lazy var c : DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        
        return f
    }()
    
    func setupCellBeforeDisplay(_ cellState: CellState, date: Date) {
        let routines = RepositoryStream.sharedInstance.getRoutinesForDate(cellState.date)
        
        if (routines.count > 0) {
            self.dot.isHidden = false
        } else {
            self.dot.isHidden = true
        }
        
        self.dot.layer.cornerRadius = self.dot.frame.width / 2
        self.selectedView.layer.cornerRadius = self.selectedView.frame.width / 2
        
        // Setup Cell text
        self.dayLabel.text = cellState.text
        
        // Mark todays date
        if (c.string(from: date) == todayDate) {
            selectedView.backgroundColor = UIColor.primaryDark()
        } else {
            selectedView.backgroundColor = UIColor.white
        }
        
        configureTextColor(cellState)
        
        delayRunOnMainThread(0.0) {
            self.configureViewIntoBubbleView(cellState)
        }
        
        configureVisibility(cellState)
    }
    
    func delayRunOnMainThread(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() +
                Double(Int64(delay * Double(NSEC_PER_SEC))) /
                Double(NSEC_PER_SEC), execute: closure)
    }
    
    func configureVisibility(_ cellState: CellState) {
        self.isHidden = false
    }
    
    func configureTextColor(_ cellState: CellState) {
        if cellState.isSelected {
            if (c.string(from: cellState.date as Date) == todayDate) {
                dayLabel.textColor = UIColor.white
            } else {
                dayLabel.textColor = UIColor.black
            }
        } else if cellState.dateBelongsTo == .thisMonth {
            dayLabel.textColor = UIColor.black
        } else {
            dayLabel.textColor = UIColor.primaryDark()
        }
    }
    
    func cellSelectionChanged(_ cellState: CellState) {
        if cellState.isSelected == true {
            if selectedView.isHidden == true {
                configureViewIntoBubbleView(cellState)
                selectedView.animateWithBounceEffect(withCompletionHandler: nil)
            }
        } else {
            configureViewIntoBubbleView(cellState, animateDeselection: true)
        }
    }
    
    fileprivate func configureViewIntoBubbleView(_ cellState: CellState, animateDeselection: Bool = false) {
        if cellState.isSelected {
            self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
            self.selectedView.isHidden = false
            self.dot.isHidden = true
            
            self.configureTextColor(cellState)
        } else {
            if animateDeselection {
                self.configureTextColor(cellState)
                
                if self.selectedView.isHidden == false {
                    self.selectedView.animateWithFadeEffect(withCompletionHandler: { () -> Void in
                        self.selectedView.isHidden = true
                        self.selectedView.alpha = 1
                    })
                }
            } else {
                self.selectedView.isHidden = true
            }
            
            let routines = RepositoryStream.sharedInstance.getRoutinesForDate(cellState.date)
            
            if (routines.count > 0) {
                self.dot.isHidden = false
            } else {
                self.dot.isHidden = true
            }
        }
    }
}
import UIKit

class AnimationView: UIView {
    func animateWithBounceEffect(withCompletionHandler completionHandler:(() -> Void)?) {
        let viewAnimation = AnimationClass.BounceEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
    
    func animateWithFadeEffect(withCompletionHandler completionHandler:(() -> Void)?) {
        let viewAnimation = AnimationClass.fadeOutEffect()
        viewAnimation(self) { _ in
            completionHandler?()
        }
    }
}

class AnimationClass {
    class func BounceEffect() -> (UIView, @escaping (Bool) -> Void) -> () {
        return {
            view, completion in
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(
                withDuration: 0.5,
                delay: 0, usingSpringWithDamping: 0.3,
                initialSpringVelocity: 0.1,
                options: UIViewAnimationOptions.beginFromCurrentState,
                animations: {
                    view.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
                completion: completion
            )
        }
    }
    
    class func fadeOutEffect() -> (UIView, @escaping (Bool) -> Void) -> () {
        return {
            view, completion in
            UIView.animate(withDuration: 0.6,
                           delay: 0, usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                            view.alpha = 0
            },
                           completion: completion)
        }
    }
}
