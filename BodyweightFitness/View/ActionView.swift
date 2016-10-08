import UIKit

@IBDesignable
class ActionView: UIButton {
    let horizontalPadding: CGFloat = 14.0
    var buttonColor: UIColor?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        customizeAppearance()
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//        
//        customizeAppearance()
//    }
//    
//    override func drawRect(rect: CGRect) {
//        layer.borderColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1).CGColor
//        layer.backgroundColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1).CGColor
//        
//        setTitleColor(tintColor, forState: UIControlState.Normal)
//        setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
//    }
//    
//    func customizeAppearance() {
//        let containsEdgeInsets = !UIEdgeInsetsEqualToEdgeInsets(contentEdgeInsets, UIEdgeInsetsZero)
//        
//        contentEdgeInsets = containsEdgeInsets ? contentEdgeInsets : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        
//        layer.borderWidth = 0.0
//        layer.borderColor = UIColor(red:0, green:0.27, blue:0.24, alpha:1).CGColor
//        layer.cornerRadius = frame.size.height / 2.0
//        layer.masksToBounds = false
//        
//        layer.shadowColor = UIColor.blackColor().CGColor
//        layer.shadowOpacity = 0.4
//        layer.shadowRadius = 1
//        layer.shadowOffset = CGSizeMake(0, 2)
//    }
//    
//    override var tintColor: UIColor! {
//        get {
//            if let color = buttonColor {
//                return color
//            } else {
//                return super.tintColor
//            }
//        }
//        
//        set {
//            super.tintColor = newValue
//            buttonColor = newValue
//        }
//    }
}
