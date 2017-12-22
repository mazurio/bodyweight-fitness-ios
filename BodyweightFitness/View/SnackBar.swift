import UIKit

// MARK: - enums

@objc public enum CWNotificationStyle : Int {
    case statusBarNotification
    case navigationBarNotification
}

@objc public enum CWNotificationAnimationStyle : Int {
    case top
    case bottom
    case left
    case right
}

@objc public enum CWNotificationAnimationType : Int {
    case replace
    case overlay
}

// MARK: - CWStatusBarNotification

open class CWStatusBarNotification : NSObject {
    // MARK: - properties
    
    fileprivate let fontSize : CGFloat = 10.0
    
    fileprivate var tapGestureRecognizer : UITapGestureRecognizer!
    fileprivate var dismissHandle : CWDelayedClosureHandle?
    fileprivate var isCustomView : Bool
    
    open var notificationLabel : ScrollLabel?
    open var statusBarView : UIView?
    open var notificationTappedClosure : () -> ()
    open var notificationIsShowing = false
    open var notificationIsDismissing = false
    open var notificationWindow : CWWindowContainer?
    
    open var notificationLabelBackgroundColor : UIColor
    open var notificationLabelTextColor : UIColor
    open var notificationLabelFont : UIFont
    open var notificationLabelHeight : CGFloat
    open var customView : UIView?
    open var multiline : Bool
    open var supportedInterfaceOrientations : UIInterfaceOrientationMask
    open var notificationAnimationDuration : TimeInterval
    open var notificationStyle : CWNotificationStyle
    open var notificationAnimationInStyle : CWNotificationAnimationStyle
    open var notificationAnimationOutStyle : CWNotificationAnimationStyle
    open var notificationAnimationType : CWNotificationAnimationType
    open var preferredStatusBarStyle : UIStatusBarStyle
    
    // MARK: - setup
    
    public override init() {
        if let tintColor = UIApplication.shared.delegate?.window??
            .tintColor {
            self.notificationLabelBackgroundColor = tintColor
        } else {
            self.notificationLabelBackgroundColor = UIColor.black
        }
        self.notificationLabelTextColor = UIColor.white
        self.notificationLabelFont = UIFont.systemFont(ofSize: self.fontSize)
        self.notificationLabelHeight = 0.0
        self.customView = nil
        self.multiline = false
        if let supportedInterfaceOrientations = UIApplication.shared.keyWindow?.rootViewController?
            .supportedInterfaceOrientations {
            self.supportedInterfaceOrientations = supportedInterfaceOrientations
        } else {
            self.supportedInterfaceOrientations = .all
        }
        self.notificationAnimationDuration = 0.25
        self.notificationStyle = .statusBarNotification
        self.notificationAnimationInStyle = .bottom
        self.notificationAnimationOutStyle = .bottom
        self.notificationAnimationType = .replace
        self.notificationIsDismissing = false
        self.isCustomView = false
        self.preferredStatusBarStyle = .default
        self.dismissHandle = nil
        
        // make swift happy
        self.notificationTappedClosure = {}
        
        super.init()
        
        // create default tap closure
        self.notificationTappedClosure = {
            if !self.notificationIsDismissing {
                self.dismissNotification()
            }
        }
        
        // create tap recognizer
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                           action: #selector(CWStatusBarNotification.notificationTapped(_:)))
    }
    
    // MARK: - dimensions
    
    fileprivate func getStatusBarHeight() -> CGFloat {
        if self.notificationLabelHeight > 0 {
            return self.notificationLabelHeight
        }
        
        var statusBarHeight = UIApplication.shared.statusBarFrame
            .size.height
        if systemVersionLessThan("8.0.0") && UIInterfaceOrientationIsLandscape(
            UIApplication.shared.statusBarOrientation) {
            statusBarHeight = UIApplication.shared.statusBarFrame
                .size.width
        }
        return statusBarHeight > 0 ? statusBarHeight : 20
    }
    
    fileprivate func getStatusBarWidth() -> CGFloat {
        if systemVersionLessThan("8.0.0") && UIInterfaceOrientationIsLandscape(
            UIApplication.shared.statusBarOrientation) {
            return UIScreen.main.bounds.size.height
        }
        return UIScreen.main.bounds.size.width
    }
    
    fileprivate func getStatusBarOffset() -> CGFloat {
        if self.getStatusBarHeight() == 40.0 {
            return -20.0
        }
        return 0.0
    }
    
    fileprivate func getNavigationBarHeight() -> CGFloat {
        if UIInterfaceOrientationIsPortrait(UIApplication.shared
            .statusBarOrientation) || UI_USER_INTERFACE_IDIOM() == .pad {
            return 44.0
        }
        return 30.0
    }
    
    fileprivate func getNotificationLabelHeight() -> CGFloat {
        switch self.notificationStyle {
        case .navigationBarNotification:
            return self.getStatusBarHeight() + self.getNavigationBarHeight()
        case .statusBarNotification:
            fallthrough
        default:
            return self.getStatusBarHeight()
        }
    }
    
    fileprivate func getNotificationLabelTopFrame() -> CGRect {
        return CGRect(x: 0, y: self.getStatusBarOffset() + -1
            * self.getNotificationLabelHeight(), width: self.getStatusBarWidth(),
                                                 height: self.getNotificationLabelHeight())
    }
    
    fileprivate func getNotificationLabelBottomFrame() -> CGRect {
        return CGRect(x: 0, y: self.getStatusBarOffset()
            + self.getNotificationLabelHeight(), width: self.getStatusBarWidth(), height: 0)
    }
    
    fileprivate func getNotificationLabelLeftFrame() -> CGRect {
        return CGRect(x: -1 * self.getStatusBarWidth(),
                          y: self.getStatusBarOffset(), width: self.getStatusBarWidth(),
                          height: self.getNotificationLabelHeight())
    }
    
    fileprivate func getNotificationLabelRightFrame() -> CGRect {
        return CGRect(x: self.getStatusBarWidth(), y: self.getStatusBarOffset(),
                          width: self.getStatusBarWidth(), height: self.getNotificationLabelHeight())
    }
    
    fileprivate func getNotificationLabelFrame() -> CGRect {
        return CGRect(x: 0, y: self.getStatusBarOffset(),
                          width: self.getStatusBarWidth(), height: self.getNotificationLabelHeight())
    }
    
    // MARK: - screen orientation change
    
    func updateStatusBarFrame() {
        if let view = self.isCustomView ? self.customView :
            self.notificationLabel {
            view.frame = self.getNotificationLabelFrame()
        }
        if let statusBarView = self.statusBarView {
            statusBarView.isHidden = true
        }
    }
    
    // MARK: - on tap
    
    func notificationTapped(_ recognizer : UITapGestureRecognizer) {
        self.notificationTappedClosure()
    }
    
    // MARK: - display helpers
    
    fileprivate func setupNotificationView(_ view : UIView) {
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(self.tapGestureRecognizer)
        switch self.notificationAnimationInStyle {
        case .top:
            view.frame = self.getNotificationLabelTopFrame()
        case .bottom:
            view.frame = self.getNotificationLabelBottomFrame()
        case .left:
            view.frame = self.getNotificationLabelLeftFrame()
        case .right:
            view.frame = self.getNotificationLabelRightFrame()
        }
    }
    
    fileprivate func createNotificationLabelWithMessage(_ message : String) {
        self.notificationLabel = ScrollLabel()
        self.notificationLabel?.numberOfLines = self.multiline ? 0 : 1
        self.notificationLabel?.text = message
        self.notificationLabel?.textAlignment = .center
        self.notificationLabel?.adjustsFontSizeToFitWidth = false
        self.notificationLabel?.font = self.notificationLabelFont
        self.notificationLabel?.backgroundColor =
            self.notificationLabelBackgroundColor
        self.notificationLabel?.textColor = self.notificationLabelTextColor
        if self.notificationLabel != nil {
            self.setupNotificationView(self.notificationLabel!)
        }
    }
    
    fileprivate func createNotificationWithCustomView(_ view : UIView) {
        self.customView = UIView()
        // no autoresizing masks so that we can create constraints manually
        view.translatesAutoresizingMaskIntoConstraints = false
        self.customView?.addSubview(view)
        
        // setup auto layout constraints so that the custom view that is added
        // is constrained to be the same size as its superview, whose frame will
        // be altered
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .trailing, relatedBy: .equal, toItem: self.customView,
            attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .leading, relatedBy: .equal, toItem: self.customView,
            attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .top, relatedBy: .equal, toItem: self.customView,
            attribute: .top, multiplier: 1.0, constant: 0.0))
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .bottom, relatedBy: .equal, toItem: self.customView,
            attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        if self.customView != nil {
            self.setupNotificationView(self.customView!)
        }
    }
    
    fileprivate func createNotificationWindow() {
        self.notificationWindow = CWWindowContainer(
            frame: UIScreen.main.bounds)
        self.notificationWindow?.backgroundColor = UIColor.clear
        self.notificationWindow?.isUserInteractionEnabled = true
        self.notificationWindow?.autoresizingMask = UIViewAutoresizing(
            arrayLiteral: .flexibleWidth, .flexibleHeight)
        self.notificationWindow?.windowLevel = UIWindowLevelStatusBar
        let rootViewController = CWViewController()
        rootViewController.localSupportedInterfaceOrientations =
            self.supportedInterfaceOrientations
        rootViewController.localPreferredStatusBarStyle =
            self.preferredStatusBarStyle
        self.notificationWindow?.rootViewController = rootViewController
        self.notificationWindow?.notificationHeight =
            self.getNotificationLabelHeight()
    }
    
    fileprivate func createStatusBarView() {
        self.statusBarView = UIView(frame: self.getNotificationLabelFrame())
        self.statusBarView?.clipsToBounds = true
        if self.notificationAnimationType == .replace {
            let statusBarImageView = UIScreen.main
                .snapshotView(afterScreenUpdates: true)
            self.statusBarView?.addSubview(statusBarImageView)
        }
        if self.statusBarView != nil {
            self.notificationWindow?.rootViewController?.view
                .addSubview(self.statusBarView!)
            self.notificationWindow?.rootViewController?.view
                .sendSubview(toBack: self.statusBarView!)
        }
    }
    
    // MARK: - frame changing
    
    fileprivate func firstFrameChange() {
        guard let view = self.isCustomView ? self.customView :
            self.notificationLabel, self.statusBarView != nil else {
                return
        }
        view.frame = self.getNotificationLabelFrame()
        switch self.notificationAnimationInStyle {
        case .top:
            self.statusBarView!.frame = self.getNotificationLabelBottomFrame()
        case .bottom:
            self.statusBarView!.frame = self.getNotificationLabelTopFrame()
        case .left:
            self.statusBarView!.frame = self.getNotificationLabelRightFrame()
        case .right:
            self.statusBarView!.frame = self.getNotificationLabelLeftFrame()
        }
    }
    
    fileprivate func secondFrameChange() {
        guard let view = self.isCustomView ? self.customView :
            self.notificationLabel, self.statusBarView != nil else {
                return
        }
        switch self.notificationAnimationOutStyle {
        case .top:
            self.statusBarView!.frame = self.getNotificationLabelBottomFrame()
        case .bottom:
            self.statusBarView!.frame = self.getNotificationLabelTopFrame()
            view.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            view.center = CGPoint(x: view.center.x, y: self.getStatusBarOffset()
                + self.getNotificationLabelHeight())
        case .left:
            self.statusBarView!.frame = self.getNotificationLabelRightFrame()
        case .right:
            self.statusBarView!.frame = self.getNotificationLabelLeftFrame()
        }
    }
    
    fileprivate func thirdFrameChange() {
        guard let view = self.isCustomView ? self.customView :
            self.notificationLabel, self.statusBarView != nil else {
                return
        }
        self.statusBarView!.frame = self.getNotificationLabelFrame()
        switch self.notificationAnimationOutStyle {
        case .top:
            view.frame = self.getNotificationLabelTopFrame()
        case .bottom:
            view.transform = CGAffineTransform(scaleX: 1.0, y: 0.01)
        case .left:
            view.frame = self.getNotificationLabelLeftFrame()
        case .right:
            view.frame = self.getNotificationLabelRightFrame()
        }
    }
    
    // MARK: - display notification
    
    open func displayNotificationWithMessage(_ message : String,
                                               completion : @escaping () -> ()) {
        guard !self.notificationIsShowing else {
            return
        }
        self.isCustomView = false
        self.notificationIsShowing = true
        
        // create window
        self.createNotificationWindow()
        
        // create label
        self.createNotificationLabelWithMessage(message)
        
        // create status bar view
        self.createStatusBarView()
        
        // add label to window
        guard let label = self.notificationLabel else {
            return
        }
        self.notificationWindow?.rootViewController?.view.addSubview(label)
        self.notificationWindow?.rootViewController?.view.bringSubview(
            toFront: label)
        self.notificationWindow?.isHidden = false
        
        // checking for screen orientation change
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
                                                         object: nil)
        
        // checking for status bar change
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame,
                                                         object: nil)
        
        // animate
        UIView.animate(withDuration: self.notificationAnimationDuration,
                                   animations: { () -> () in
                                    self.firstFrameChange()
        }, completion: { (finished) -> () in
            if let delayInSeconds = self.notificationLabel?.scrollTime() {
                let _ = performClosureAfterDelay(Double(delayInSeconds), closure: {
                    () -> () in
                    completion()
                })
            }
        }) 
    }
    
    open func displayNotificationWithMessage(_ message : String,
                                               forDuration duration : TimeInterval) {
        self.displayNotificationWithMessage(message) { () -> () in
            self.dismissHandle = performClosureAfterDelay(duration, closure: {
                () -> () in
                self.dismissNotification()
            })
        }
    }
    
    open func displayNotificationWithAttributedString(
        _ attributedString : NSAttributedString, completion : @escaping () -> ()) {
        self.displayNotificationWithMessage(attributedString.string,
                                            completion: completion)
        self.notificationLabel?.attributedText = attributedString
    }
    
    open func displayNotificationWithAttributedString(
        _ attributedString : NSAttributedString,
        forDuration duration : TimeInterval) {
        self.displayNotificationWithMessage(attributedString.string,
                                            forDuration: duration)
        self.notificationLabel?.attributedText = attributedString
    }
    
    open func displayNotificationWithView(_ view : UIView, completion : @escaping () -> ()) {
        guard !self.notificationIsShowing else {
            return
        }
        self.isCustomView = true
        self.notificationIsShowing = true
        
        // create window
        self.createNotificationWindow()
        
        // setup custom view
        self.createNotificationWithCustomView(view)
        
        // create status bar view
        self.createStatusBarView()
        
        // add view to window
        if let rootView = self.notificationWindow?.rootViewController?.view,
            let customView = self.customView {
            rootView.addSubview(customView)
            rootView.bringSubview(toFront: customView)
            self.notificationWindow!.isHidden = false
        }
        
        // checking for screen orientation change
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
                                                         object: nil)
        
        // checking for status bar change
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame,
                                                         object: nil)
        
        // animate
        UIView.animate(withDuration: self.notificationAnimationDuration,
                                   animations: { () -> () in
                                    self.firstFrameChange()
        }, completion: { (finished) -> () in
            completion()
        }) 
    }
    
    open func displayNotificationWithView(_ view : UIView,
                                            forDuration duration : TimeInterval) {
        self.displayNotificationWithView(view) { () -> () in
            self.dismissHandle = performClosureAfterDelay(duration, closure: { () -> Void in
                self.dismissNotification()
            })
        }
    }
    
    open func dismissNotificationWithCompletion(_ completion : (() -> ())?) {
        cancelDelayedClosure(self.dismissHandle)
        self.notificationIsDismissing = true
        self.secondFrameChange()
        UIView.animate(withDuration: self.notificationAnimationDuration,
                                   animations: { () -> () in
                                    self.thirdFrameChange()
        }, completion: { (finished) -> () in
            guard let view = self.isCustomView ? self.customView :
                self.notificationLabel else {
                    return
            }
            view.removeFromSuperview()
            self.statusBarView?.removeFromSuperview()
            self.notificationWindow?.isHidden = true
            self.notificationWindow = nil
            self.customView = nil
            self.notificationLabel = nil
            self.notificationIsShowing = false
            self.notificationIsDismissing = false
            NotificationCenter.default.removeObserver(self,
                                                                name: NSNotification.Name.UIApplicationDidChangeStatusBarFrame,
                                                                object: nil)
            NotificationCenter.default.removeObserver(self,
                                                                name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame,
                                                                object: nil)
            if completion != nil {
                completion!()
            }
        }) 
    }
    
    open func dismissNotification() {
        self.dismissNotificationWithCompletion(nil)
    }
}

import UIKit

// MARK: - helper functions

func systemVersionLessThan(_ value : String) -> Bool {
    return UIDevice.current.systemVersion.compare(value,
                                                          options: NSString.CompareOptions.numeric) == .orderedAscending
}

// MARK: - ScrollLabel

open class ScrollLabel : UILabel {
    
    // MARK: - properties
    
    fileprivate let padding : CGFloat = 10.0
    fileprivate let scrollSpeed : CGFloat = 40.0
    fileprivate let scrollDelay : CGFloat = 1.0
    fileprivate var textImage : UIImageView?
    
    // MARK: - setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textImage = UIImageView()
        self.addSubview(self.textImage!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func drawText(in rect: CGRect) {
        guard self.scrollOffset() > 0 else {
            self.textImage = nil
            super.drawText(in: rect.insetBy(dx: padding, dy: 0))
            return
        }
        guard let textImage = self.textImage else {
            return
        }
        var frame = rect // because rect is immutable
        frame.size.width = self.fullWidth() + padding * 2
        UIGraphicsBeginImageContextWithOptions(frame.size, false,
                                               UIScreen.main.scale)
        super.drawText(in: frame)
        textImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        textImage.sizeToFit()
        UIView.animate(withDuration: TimeInterval(self.scrollTime()
            - scrollDelay),
                                   delay: TimeInterval(scrollDelay),
                                   options: UIViewAnimationOptions(arrayLiteral:
                                    UIViewAnimationOptions.beginFromCurrentState,
                                    UIViewAnimationOptions()),
                                   animations: { () -> () in
                                    textImage.transform = CGAffineTransform(translationX: -1
                                        * self.scrollOffset(), y: 0)
            }, completion: nil)
    }
    
    // MARK - methods
    
    fileprivate func fullWidth() -> CGFloat {
        guard let content = self.text else {
            return 0.0
        }
        let size = NSString(string: content).size(
            attributes: [NSFontAttributeName: self.font])
        return size.width
    }
    
    fileprivate func scrollOffset() -> CGFloat {
        guard self.numberOfLines == 1 else {
            return 0.0
        }
        let insetRect = self.bounds.insetBy(dx: padding, dy: 0.0)
        return max(0, self.fullWidth() - insetRect.size.width)
    }
    
    func scrollTime() -> CGFloat {
        return self.scrollOffset() > 0 ? self.scrollOffset() / scrollSpeed
            + scrollDelay : 0
    }
}

// MARK: - CWWindowContainer

open class CWWindowContainer : UIWindow {
    var notificationHeight : CGFloat = 0.0
    
    override open func hitTest(_ pt: CGPoint, with event: UIEvent?) -> UIView? {
        var height : CGFloat = 0.0
        if systemVersionLessThan("8.0.0") && UIInterfaceOrientationIsLandscape(
            UIApplication.shared.statusBarOrientation) {
            height = UIApplication.shared.statusBarFrame.size.width
        } else {
            height = UIApplication.shared.statusBarFrame.size
                .height
        }
        if pt.y > 0 && pt.y < (self.notificationHeight != 0.0 ?
            self.notificationHeight : height) {
            return super.hitTest(pt, with: event)
        }
        
        return nil
    }
}

// MARK: - CWViewController
class CWViewController : UIViewController {
    var localPreferredStatusBarStyle : UIStatusBarStyle = .default
    var localSupportedInterfaceOrientations : UIInterfaceOrientationMask = []
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.localPreferredStatusBarStyle
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return self.localSupportedInterfaceOrientations
    }
    
    override var prefersStatusBarHidden : Bool {
        let statusBarHeight = UIApplication.shared.statusBarFrame
            .size.height
        return !(statusBarHeight > 0)
    }
}

// MARK: - delayed closure handle

typealias CWDelayedClosureHandle = (Bool) -> ()

func performClosureAfterDelay(_ seconds : Double, closure: (() -> ())?) -> CWDelayedClosureHandle? {
    guard closure != nil else {
        return nil
    }
    
    var closureToExecute : (() -> ())! = closure // copy?
    var delayHandleCopy : CWDelayedClosureHandle! = nil
    
    let delayHandle : CWDelayedClosureHandle = {
        (cancel : Bool) -> () in
        if !cancel && closureToExecute != nil {
            DispatchQueue.main.async(execute: closureToExecute)
        }
        closureToExecute = nil
        delayHandleCopy = nil
    }
    
    delayHandleCopy = delayHandle
    
    let delay = Int64(Double(seconds) * Double(NSEC_PER_SEC))
    let after = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: after) {
        if delayHandleCopy != nil {
            delayHandleCopy(false)
        }
    }
    
    return delayHandleCopy
}

func cancelDelayedClosure(_ delayedHandle : CWDelayedClosureHandle!) {
    guard delayedHandle != nil else {
        return
    }
    
    delayedHandle(true)
}
