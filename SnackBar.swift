import UIKit

// MARK: - enums

@objc public enum CWNotificationStyle : Int {
    case StatusBarNotification
    case NavigationBarNotification
}

@objc public enum CWNotificationAnimationStyle : Int {
    case Top
    case Bottom
    case Left
    case Right
}

@objc public enum CWNotificationAnimationType : Int {
    case Replace
    case Overlay
}

// MARK: - CWStatusBarNotification

public class CWStatusBarNotification : NSObject {
    // MARK: - properties
    
    private let fontSize : CGFloat = 10.0
    
    private var tapGestureRecognizer : UITapGestureRecognizer!
    private var dismissHandle : CWDelayedClosureHandle?
    private var isCustomView : Bool
    
    public var notificationLabel : ScrollLabel?
    public var statusBarView : UIView?
    public var notificationTappedClosure : () -> ()
    public var notificationIsShowing = false
    public var notificationIsDismissing = false
    public var notificationWindow : CWWindowContainer?
    
    public var notificationLabelBackgroundColor : UIColor
    public var notificationLabelTextColor : UIColor
    public var notificationLabelFont : UIFont
    public var notificationLabelHeight : CGFloat
    public var customView : UIView?
    public var multiline : Bool
    public var supportedInterfaceOrientations : UIInterfaceOrientationMask
    public var notificationAnimationDuration : NSTimeInterval
    public var notificationStyle : CWNotificationStyle
    public var notificationAnimationInStyle : CWNotificationAnimationStyle
    public var notificationAnimationOutStyle : CWNotificationAnimationStyle
    public var notificationAnimationType : CWNotificationAnimationType
    public var preferredStatusBarStyle : UIStatusBarStyle
    
    // MARK: - setup
    
    public override init() {
        if let tintColor = UIApplication.sharedApplication().delegate?.window??
            .tintColor {
            self.notificationLabelBackgroundColor = tintColor
        } else {
            self.notificationLabelBackgroundColor = UIColor.blackColor()
        }
        self.notificationLabelTextColor = UIColor.whiteColor()
        self.notificationLabelFont = UIFont.systemFontOfSize(self.fontSize)
        self.notificationLabelHeight = 0.0
        self.customView = nil
        self.multiline = false
        if let supportedInterfaceOrientations = UIApplication
            .sharedApplication().keyWindow?.rootViewController?
            .supportedInterfaceOrientations() {
            self.supportedInterfaceOrientations = supportedInterfaceOrientations
        } else {
            self.supportedInterfaceOrientations = .All
        }
        self.notificationAnimationDuration = 0.25
        self.notificationStyle = .StatusBarNotification
        self.notificationAnimationInStyle = .Bottom
        self.notificationAnimationOutStyle = .Bottom
        self.notificationAnimationType = .Replace
        self.notificationIsDismissing = false
        self.isCustomView = false
        self.preferredStatusBarStyle = .Default
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
    
    private func getStatusBarHeight() -> CGFloat {
        if self.notificationLabelHeight > 0 {
            return self.notificationLabelHeight
        }
        
        var statusBarHeight = UIApplication.sharedApplication().statusBarFrame
            .size.height
        if systemVersionLessThan("8.0.0") && UIInterfaceOrientationIsLandscape(
            UIApplication.sharedApplication().statusBarOrientation) {
            statusBarHeight = UIApplication.sharedApplication().statusBarFrame
                .size.width
        }
        return statusBarHeight > 0 ? statusBarHeight : 20
    }
    
    private func getStatusBarWidth() -> CGFloat {
        if systemVersionLessThan("8.0.0") && UIInterfaceOrientationIsLandscape(
            UIApplication.sharedApplication().statusBarOrientation) {
            return UIScreen.mainScreen().bounds.size.height
        }
        return UIScreen.mainScreen().bounds.size.width
    }
    
    private func getStatusBarOffset() -> CGFloat {
        if self.getStatusBarHeight() == 40.0 {
            return -20.0
        }
        return 0.0
    }
    
    private func getNavigationBarHeight() -> CGFloat {
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication()
            .statusBarOrientation) || UI_USER_INTERFACE_IDIOM() == .Pad {
            return 44.0
        }
        return 30.0
    }
    
    private func getNotificationLabelHeight() -> CGFloat {
        switch self.notificationStyle {
        case .NavigationBarNotification:
            return self.getStatusBarHeight() + self.getNavigationBarHeight()
        case .StatusBarNotification:
            fallthrough
        default:
            return self.getStatusBarHeight()
        }
    }
    
    private func getNotificationLabelTopFrame() -> CGRect {
        return CGRectMake(0, self.getStatusBarOffset() + -1
            * self.getNotificationLabelHeight(), self.getStatusBarWidth(),
                                                 self.getNotificationLabelHeight())
    }
    
    private func getNotificationLabelBottomFrame() -> CGRect {
        return CGRectMake(0, self.getStatusBarOffset()
            + self.getNotificationLabelHeight(), self.getStatusBarWidth(), 0)
    }
    
    private func getNotificationLabelLeftFrame() -> CGRect {
        return CGRectMake(-1 * self.getStatusBarWidth(),
                          self.getStatusBarOffset(), self.getStatusBarWidth(),
                          self.getNotificationLabelHeight())
    }
    
    private func getNotificationLabelRightFrame() -> CGRect {
        return CGRectMake(self.getStatusBarWidth(), self.getStatusBarOffset(),
                          self.getStatusBarWidth(), self.getNotificationLabelHeight())
    }
    
    private func getNotificationLabelFrame() -> CGRect {
        return CGRectMake(0, self.getStatusBarOffset(),
                          self.getStatusBarWidth(), self.getNotificationLabelHeight())
    }
    
    // MARK: - screen orientation change
    
    func updateStatusBarFrame() {
        if let view = self.isCustomView ? self.customView :
            self.notificationLabel {
            view.frame = self.getNotificationLabelFrame()
        }
        if let statusBarView = self.statusBarView {
            statusBarView.hidden = true
        }
    }
    
    // MARK: - on tap
    
    func notificationTapped(recognizer : UITapGestureRecognizer) {
        self.notificationTappedClosure()
    }
    
    // MARK: - display helpers
    
    private func setupNotificationView(view : UIView) {
        view.clipsToBounds = true
        view.userInteractionEnabled = true
        view.addGestureRecognizer(self.tapGestureRecognizer)
        switch self.notificationAnimationInStyle {
        case .Top:
            view.frame = self.getNotificationLabelTopFrame()
        case .Bottom:
            view.frame = self.getNotificationLabelBottomFrame()
        case .Left:
            view.frame = self.getNotificationLabelLeftFrame()
        case .Right:
            view.frame = self.getNotificationLabelRightFrame()
        }
    }
    
    private func createNotificationLabelWithMessage(message : String) {
        self.notificationLabel = ScrollLabel()
        self.notificationLabel?.numberOfLines = self.multiline ? 0 : 1
        self.notificationLabel?.text = message
        self.notificationLabel?.textAlignment = .Center
        self.notificationLabel?.adjustsFontSizeToFitWidth = false
        self.notificationLabel?.font = self.notificationLabelFont
        self.notificationLabel?.backgroundColor =
            self.notificationLabelBackgroundColor
        self.notificationLabel?.textColor = self.notificationLabelTextColor
        if self.notificationLabel != nil {
            self.setupNotificationView(self.notificationLabel!)
        }
    }
    
    private func createNotificationWithCustomView(view : UIView) {
        self.customView = UIView()
        // no autoresizing masks so that we can create constraints manually
        view.translatesAutoresizingMaskIntoConstraints = false
        self.customView?.addSubview(view)
        
        // setup auto layout constraints so that the custom view that is added
        // is constrained to be the same size as its superview, whose frame will
        // be altered
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .Trailing, relatedBy: .Equal, toItem: self.customView,
            attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .Leading, relatedBy: .Equal, toItem: self.customView,
            attribute: .Leading, multiplier: 1.0, constant: 0.0))
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .Top, relatedBy: .Equal, toItem: self.customView,
            attribute: .Top, multiplier: 1.0, constant: 0.0))
        self.customView?.addConstraint(NSLayoutConstraint(item: view,
            attribute: .Bottom, relatedBy: .Equal, toItem: self.customView,
            attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        
        if self.customView != nil {
            self.setupNotificationView(self.customView!)
        }
    }
    
    private func createNotificationWindow() {
        self.notificationWindow = CWWindowContainer(
            frame: UIScreen.mainScreen().bounds)
        self.notificationWindow?.backgroundColor = UIColor.clearColor()
        self.notificationWindow?.userInteractionEnabled = true
        self.notificationWindow?.autoresizingMask = UIViewAutoresizing(
            arrayLiteral: .FlexibleWidth, .FlexibleHeight)
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
    
    private func createStatusBarView() {
        self.statusBarView = UIView(frame: self.getNotificationLabelFrame())
        self.statusBarView?.clipsToBounds = true
        if self.notificationAnimationType == .Replace {
            let statusBarImageView = UIScreen.mainScreen()
                .snapshotViewAfterScreenUpdates(true)
            self.statusBarView?.addSubview(statusBarImageView)
        }
        if self.statusBarView != nil {
            self.notificationWindow?.rootViewController?.view
                .addSubview(self.statusBarView!)
            self.notificationWindow?.rootViewController?.view
                .sendSubviewToBack(self.statusBarView!)
        }
    }
    
    // MARK: - frame changing
    
    private func firstFrameChange() {
        guard let view = self.isCustomView ? self.customView :
            self.notificationLabel where self.statusBarView != nil else {
                return
        }
        view.frame = self.getNotificationLabelFrame()
        switch self.notificationAnimationInStyle {
        case .Top:
            self.statusBarView!.frame = self.getNotificationLabelBottomFrame()
        case .Bottom:
            self.statusBarView!.frame = self.getNotificationLabelTopFrame()
        case .Left:
            self.statusBarView!.frame = self.getNotificationLabelRightFrame()
        case .Right:
            self.statusBarView!.frame = self.getNotificationLabelLeftFrame()
        }
    }
    
    private func secondFrameChange() {
        guard let view = self.isCustomView ? self.customView :
            self.notificationLabel where self.statusBarView != nil else {
                return
        }
        switch self.notificationAnimationOutStyle {
        case .Top:
            self.statusBarView!.frame = self.getNotificationLabelBottomFrame()
        case .Bottom:
            self.statusBarView!.frame = self.getNotificationLabelTopFrame()
            view.layer.anchorPoint = CGPointMake(0.5, 1.0)
            view.center = CGPointMake(view.center.x, self.getStatusBarOffset()
                + self.getNotificationLabelHeight())
        case .Left:
            self.statusBarView!.frame = self.getNotificationLabelRightFrame()
        case .Right:
            self.statusBarView!.frame = self.getNotificationLabelLeftFrame()
        }
    }
    
    private func thirdFrameChange() {
        guard let view = self.isCustomView ? self.customView :
            self.notificationLabel where self.statusBarView != nil else {
                return
        }
        self.statusBarView!.frame = self.getNotificationLabelFrame()
        switch self.notificationAnimationOutStyle {
        case .Top:
            view.frame = self.getNotificationLabelTopFrame()
        case .Bottom:
            view.transform = CGAffineTransformMakeScale(1.0, 0.01)
        case .Left:
            view.frame = self.getNotificationLabelLeftFrame()
        case .Right:
            view.frame = self.getNotificationLabelRightFrame()
        }
    }
    
    // MARK: - display notification
    
    public func displayNotificationWithMessage(message : String,
                                               completion : () -> ()) {
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
        self.notificationWindow?.rootViewController?.view.bringSubviewToFront(
            label)
        self.notificationWindow?.hidden = false
        
        // checking for screen orientation change
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: UIApplicationDidChangeStatusBarFrameNotification,
                                                         object: nil)
        
        // checking for status bar change
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: UIApplicationWillChangeStatusBarFrameNotification,
                                                         object: nil)
        
        // animate
        UIView.animateWithDuration(self.notificationAnimationDuration,
                                   animations: { () -> () in
                                    self.firstFrameChange()
        }) { (finished) -> () in
            if let delayInSeconds = self.notificationLabel?.scrollTime() {
                performClosureAfterDelay(Double(delayInSeconds), closure: {
                    () -> () in
                    completion()
                })
            }
        }
    }
    
    public func displayNotificationWithMessage(message : String,
                                               forDuration duration : NSTimeInterval) {
        self.displayNotificationWithMessage(message) { () -> () in
            self.dismissHandle = performClosureAfterDelay(duration, closure: {
                () -> () in
                self.dismissNotification()
            })
        }
    }
    
    public func displayNotificationWithAttributedString(
        attributedString : NSAttributedString, completion : () -> ()) {
        self.displayNotificationWithMessage(attributedString.string,
                                            completion: completion)
        self.notificationLabel?.attributedText = attributedString
    }
    
    public func displayNotificationWithAttributedString(
        attributedString : NSAttributedString,
        forDuration duration : NSTimeInterval) {
        self.displayNotificationWithMessage(attributedString.string,
                                            forDuration: duration)
        self.notificationLabel?.attributedText = attributedString
    }
    
    public func displayNotificationWithView(view : UIView, completion : () -> ()) {
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
            rootView.bringSubviewToFront(customView)
            self.notificationWindow!.hidden = false
        }
        
        // checking for screen orientation change
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: UIApplicationDidChangeStatusBarFrameNotification,
                                                         object: nil)
        
        // checking for status bar change
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CWStatusBarNotification.updateStatusBarFrame),
                                                         name: UIApplicationWillChangeStatusBarFrameNotification,
                                                         object: nil)
        
        // animate
        UIView.animateWithDuration(self.notificationAnimationDuration,
                                   animations: { () -> () in
                                    self.firstFrameChange()
        }) { (finished) -> () in
            completion()
        }
    }
    
    public func displayNotificationWithView(view : UIView,
                                            forDuration duration : NSTimeInterval) {
        self.displayNotificationWithView(view) { () -> () in
            self.dismissHandle = performClosureAfterDelay(duration, closure: { () -> Void in
                self.dismissNotification()
            })
        }
    }
    
    public func dismissNotificationWithCompletion(completion : (() -> ())?) {
        cancelDelayedClosure(self.dismissHandle)
        self.notificationIsDismissing = true
        self.secondFrameChange()
        UIView.animateWithDuration(self.notificationAnimationDuration,
                                   animations: { () -> () in
                                    self.thirdFrameChange()
        }) { (finished) -> () in
            guard let view = self.isCustomView ? self.customView :
                self.notificationLabel else {
                    return
            }
            view.removeFromSuperview()
            self.statusBarView?.removeFromSuperview()
            self.notificationWindow?.hidden = true
            self.notificationWindow = nil
            self.customView = nil
            self.notificationLabel = nil
            self.notificationIsShowing = false
            self.notificationIsDismissing = false
            NSNotificationCenter.defaultCenter().removeObserver(self,
                                                                name: UIApplicationDidChangeStatusBarFrameNotification,
                                                                object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self,
                                                                name: UIApplicationWillChangeStatusBarFrameNotification,
                                                                object: nil)
            if completion != nil {
                completion!()
            }
        }
    }
    
    public func dismissNotification() {
        self.dismissNotificationWithCompletion(nil)
    }
}

import UIKit

// MARK: - helper functions

func systemVersionLessThan(value : String) -> Bool {
    return UIDevice.currentDevice().systemVersion.compare(value,
                                                          options: NSStringCompareOptions.NumericSearch) == .OrderedAscending
}

// MARK: - ScrollLabel

public class ScrollLabel : UILabel {
    
    // MARK: - properties
    
    private let padding : CGFloat = 10.0
    private let scrollSpeed : CGFloat = 40.0
    private let scrollDelay : CGFloat = 1.0
    private var textImage : UIImageView?
    
    // MARK: - setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textImage = UIImageView()
        self.addSubview(self.textImage!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func drawTextInRect(rect: CGRect) {
        guard self.scrollOffset() > 0 else {
            self.textImage = nil
            super.drawTextInRect(CGRectInset(rect, padding, 0))
            return
        }
        guard let textImage = self.textImage else {
            return
        }
        var frame = rect // because rect is immutable
        frame.size.width = self.fullWidth() + padding * 2
        UIGraphicsBeginImageContextWithOptions(frame.size, false,
                                               UIScreen.mainScreen().scale)
        super.drawTextInRect(frame)
        textImage.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        textImage.sizeToFit()
        UIView.animateWithDuration(NSTimeInterval(self.scrollTime()
            - scrollDelay),
                                   delay: NSTimeInterval(scrollDelay),
                                   options: UIViewAnimationOptions(arrayLiteral:
                                    UIViewAnimationOptions.BeginFromCurrentState,
                                    UIViewAnimationOptions.CurveEaseInOut),
                                   animations: { () -> () in
                                    textImage.transform = CGAffineTransformMakeTranslation(-1
                                        * self.scrollOffset(), 0)
            }, completion: nil)
    }
    
    // MARK - methods
    
    private func fullWidth() -> CGFloat {
        guard let content = self.text else {
            return 0.0
        }
        let size = NSString(string: content).sizeWithAttributes(
            [NSFontAttributeName: self.font])
        return size.width
    }
    
    private func scrollOffset() -> CGFloat {
        guard self.numberOfLines == 1 else {
            return 0.0
        }
        let insetRect = CGRectInset(self.bounds, padding, 0.0)
        return max(0, self.fullWidth() - insetRect.size.width)
    }
    
    func scrollTime() -> CGFloat {
        return self.scrollOffset() > 0 ? self.scrollOffset() / scrollSpeed
            + scrollDelay : 0
    }
}

// MARK: - CWWindowContainer

public class CWWindowContainer : UIWindow {
    var notificationHeight : CGFloat = 0.0
    
    override public func hitTest(pt: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var height : CGFloat = 0.0
        if systemVersionLessThan("8.0.0") && UIInterfaceOrientationIsLandscape(
            UIApplication.sharedApplication().statusBarOrientation) {
            height = UIApplication.sharedApplication().statusBarFrame.size.width
        } else {
            height = UIApplication.sharedApplication().statusBarFrame.size
                .height
        }
        if pt.y > 0 && pt.y < (self.notificationHeight != 0.0 ?
            self.notificationHeight : height) {
            return super.hitTest(pt, withEvent: event)
        }
        
        return nil
    }
}

// MARK: - CWViewController
class CWViewController : UIViewController {
    var localPreferredStatusBarStyle : UIStatusBarStyle = .Default
    var localSupportedInterfaceOrientations : UIInterfaceOrientationMask = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return self.localPreferredStatusBarStyle
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return self.localSupportedInterfaceOrientations
    }
    
    override func prefersStatusBarHidden() -> Bool {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame
            .size.height
        return !(statusBarHeight > 0)
    }
}

// MARK: - delayed closure handle

typealias CWDelayedClosureHandle = (Bool) -> ()

func performClosureAfterDelay(seconds : Double, closure: dispatch_block_t?) -> CWDelayedClosureHandle? {
    guard closure != nil else {
        return nil
    }
    
    var closureToExecute : dispatch_block_t! = closure // copy?
    var delayHandleCopy : CWDelayedClosureHandle! = nil
    
    let delayHandle : CWDelayedClosureHandle = {
        (cancel : Bool) -> () in
        if !cancel && closureToExecute != nil {
            dispatch_async(dispatch_get_main_queue(), closureToExecute)
        }
        closureToExecute = nil
        delayHandleCopy = nil
    }
    
    delayHandleCopy = delayHandle
    
    let delay = Int64(Double(seconds) * Double(NSEC_PER_SEC))
    let after = dispatch_time(DISPATCH_TIME_NOW, delay)
    dispatch_after(after, dispatch_get_main_queue()) {
        if delayHandleCopy != nil {
            delayHandleCopy(false)
        }
    }
    
    return delayHandleCopy
}

func cancelDelayedClosure(delayedHandle : CWDelayedClosureHandle!) {
    guard delayedHandle != nil else {
        return
    }
    
    delayedHandle(true)
}