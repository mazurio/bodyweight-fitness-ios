import UIKit

@IBDesignable
class CardView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 3

    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor(red: 0.82, green: 0.82, blue: 0.83, alpha: 1.00)
    @IBInspectable var shadowOpacity: Float = 0.2

    override func layoutSubviews() {
        self.backgroundColor = UIColor.white
        
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

@IBDesignable
class ProgressView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 2

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
    }

    func setCompletionRate(_ completionRate: CompletionRate) {
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
