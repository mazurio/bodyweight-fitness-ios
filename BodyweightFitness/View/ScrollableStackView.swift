import UIKit

@IBDesignable
@objc public class ScrollableStackView: UIView {
    
    fileprivate var didSetupConstraints = false
    public private(set) var scrollView: UIScrollView!
    @objc open var stackView: UIStackView!
    @objc @IBInspectable open var spacing: CGFloat = 8
    @objc open var durationForAnimations:TimeInterval = 1.45
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        // ScrollView
        scrollView = UIScrollView(frame: self.frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.layoutMargins = .zero
        self.addSubview(scrollView)
        
        // StackView
        stackView = UIStackView(frame: scrollView.frame)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.distribution = .equalSpacing
        scrollView.addSubview(stackView)
    }
    
    //MARK: View life cycle
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupUI()
    }
    
    //MARK: UI
    func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        self.setNeedsUpdateConstraints() // Bootstrap auto layout
    }
    
    // Scrolls to item at index
    @objc public func scrollToItem(index: Int) {
        if stackView.arrangedSubviews.count > 0 {
            let view = stackView.arrangedSubviews[index]
            
            UIView.animate(withDuration: durationForAnimations, animations: {
                self.scrollView.setContentOffset(CGPoint(x: 0, y:view.frame.origin.y), animated: true)
            })
        }
    }
    
    // Used to scroll till the end of scrollview
    @objc public func scrollToBottom() {
        if stackView.arrangedSubviews.count > 0 {
            UIView.animate(withDuration: durationForAnimations, animations: {
                self.scrollView.scrollToBottom(true)
            })
        }
    }
    
    // Scrolls to top of scrollable area
    @objc public func scrollToTop() {
        if stackView.arrangedSubviews.count > 0 {
            UIView.animate(withDuration: durationForAnimations, animations: {
                self.scrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
            })
        }
    }
    
    func addItemToStack() {
        let random = CGFloat(arc4random_uniform(131) + 30) // between 30-130
        let rectangle = UIView(frame: CGRect(x: 0, y: 0, width: random, height: random))
        rectangle.backgroundColor = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
        rectangle.heightAnchor.constraint(equalToConstant: random).isActive = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.stackView.addArrangedSubview(rectangle)
        }) { (isDone) in
            if(isDone) {
                self.scrollView.scrollToBottom(true)
            }
        }
    }
    
    func removeItemFromStack() {
        UIView.animate(withDuration: 0.25, animations: {
            if let last = self.stackView.arrangedSubviews.last {
                self.stackView.removeArrangedSubview(last)
            }
        }) { (isDone) in
            if(isDone) {
                self.scrollView.scrollToBottom(true)
            }
        }
    }
    
    // Auto Layout
    override public func updateConstraints() {
        super.updateConstraints()
        
        if (!didSetupConstraints) {
            addConstraint(NSLayoutConstraint(item: scrollView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: scrollView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
            addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]-|", options: [], metrics: nil, views: ["stackView": stackView]))
            
            let margins = scrollView.layoutMarginsGuide
            stackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
            
            didSetupConstraints = true
        }
    }
}

// Used to scroll till the end of scrollview
extension UIScrollView {
    func scrollToBottom(_ animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}
