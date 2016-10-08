import UIKit

@IBDesignable
class CardView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 2

    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.blackColor()
    @IBInspectable var shadowOpacity: Float = 0.2

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.CGColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.CGPath
    }
}

@IBDesignable
class ProgressView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 2

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
    }

    func setCompletionRate(completionRate: CompletionRate) {
        if (completionRate.percentage <= 10) {
            widthConstraint.constant = 20
        } else {
            let percentage = completionRate.percentage * 2

            if (percentage >= 250) {
                widthConstraint.constant = 250
            } else {
                widthConstraint.constant = CGFloat(percentage)
            }
        }
    }
}