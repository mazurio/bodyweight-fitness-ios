/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of Material nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Rewritten to remove the functionality we don't need.
 */

import UIKit

public extension UIViewController {
	public var sideNavigationController: SideNavigationController? {
		var viewController: UIViewController? = self
		
        while nil != viewController {
			if viewController is SideNavigationController {
				return viewController as? SideNavigationController
			}
		
            viewController = viewController?.parentViewController
		}
        
		return nil
	}
}

public class SideNavigationView: UIView {
    @IBInspectable public var x: CGFloat {
        get {
            return layer.frame.origin.x
        }
        set(value) {
            layer.frame.origin.x = value
        }
    }

    @IBInspectable public var y: CGFloat {
        get {
            return layer.frame.origin.y
        }
        set(value) {
            layer.frame.origin.y = value
        }
    }

    @IBInspectable public var width: CGFloat {
        get {
            return layer.frame.size.width
        }
        set(value) {
            layer.frame.size.width = value
        }
    }

    @IBInspectable public var height: CGFloat {
        get {
            return layer.frame.size.height
        }
        set(value) {
            layer.frame.size.height = value
        }
    }

    @IBInspectable public var position: CGPoint {
        get {
            return layer.position
        }
        set(value) {
            layer.position = value
        }
    }
    
    @IBInspectable public var zPosition: CGFloat {
        get {
            return layer.zPosition
        }
        set(value) {
            layer.zPosition = value
        }
    }
    
    @IBInspectable public var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set(value) {
            layer.shadowPath = value
        }
    }
    
    @IBInspectable public var shadowPathAutoSizeEnabled: Bool = true {
        didSet {
            if shadowPathAutoSizeEnabled {
                layoutShadowPath()
            } else {
                shadowPath = nil
            }
        }
    }
    
    internal func layoutShadowPath() {
        //		if shadowPathAutoSizeEnabled {
        //			if .None == depth {
        //				shadowPath = nil
        //			} else if nil == shadowPath {
        //				shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).CGPath
        //			} else {
        //				animate(MaterialAnimation.shadowPath(UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).CGPath, duration: 0))
        //			}
        //		}
    }
}

public class SideNavigationController : UIViewController, UIGestureRecognizerDelegate {
	private var originalX: CGFloat = 0
	
	internal private(set) var panGesture: UIPanGestureRecognizer?
	internal private(set) var tapGesture: UITapGestureRecognizer?
	
	@IBInspectable public var leftThreshold: CGFloat?
	private var leftViewThreshold: CGFloat = 0
	
	@IBInspectable public var userInteractionEnabled: Bool {
		get {
			return rootViewController.view.userInteractionEnabled
		}
        
		set(value) {
			rootViewController.view.userInteractionEnabled = value
		}
	}
	
	@IBInspectable public var animationDuration: CGFloat = 0.25
	
	@IBInspectable public var enabled: Bool = true
	
	public private(set) var leftView: SideNavigationView?
	
	public var opened: Bool {
		guard nil != leftView else {
			return false
		}
        
		return leftView!.x != -leftViewWidth
	}
	
	public private(set) var rootViewController: UIViewController!
	public private(set) var leftViewController: UIViewController?

	@IBInspectable public private(set) var leftViewWidth: CGFloat!

	public convenience init(rootViewController: UIViewController, leftViewController: UIViewController? = nil) {
		self.init()
        
		self.rootViewController = rootViewController
		self.leftViewController = leftViewController
        
		prepareView()
	}
	
	public override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
        
		layoutSubviews()
	}
	

	public func transitionFromRootViewController(toViewController: UIViewController, duration: NSTimeInterval = 0.5, options: UIViewAnimationOptions = [], animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
		
        rootViewController.willMoveToParentViewController(nil)
		
        addChildViewController(toViewController)
		
        self.dimView?.removeFromSuperview()
        self.dimView = nil
        
        toViewController.view.frame = rootViewController.view.frame
        
		transitionFromViewController(rootViewController,
			toViewController: toViewController,
			duration: duration,
			options: options,
			animations: animations,
			completion: { [unowned self] (result: Bool) in
				toViewController.didMoveToParentViewController(self)
                
				self.rootViewController.removeFromParentViewController()
				self.rootViewController = toViewController
				self.rootViewController.view.clipsToBounds = true
				self.rootViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                
				self.view.sendSubviewToBack(self.rootViewController.view)
                
				completion?(result)
			})
	}
	
	public func setLeftViewWidth(width: CGFloat, hidden: Bool, animated: Bool, duration: NSTimeInterval = 0.5) {
		if let v: SideNavigationView = leftView {
			leftViewWidth = width
			
			if animated {
				v.shadowPathAutoSizeEnabled = false
				
				if hidden {
					UIView.animateWithDuration(duration,
						animations: { [unowned self] in
							v.bounds.size.width = width
							v.position.x = -width / 2
                            self.dimView?.alpha = 0
						}) { [unowned self] _ in
							v.shadowPathAutoSizeEnabled = true
							self.layoutSubviews()
							self.hideView(v)
						}
				} else {
					UIView.animateWithDuration(duration,
						animations: { [unowned self] in
							v.bounds.size.width = width
							v.position.x = width / 2
                            self.dimView?.alpha = 0.5
						}) { [unowned self] _ in
							v.shadowPathAutoSizeEnabled = true
							self.layoutSubviews()
							self.showView(v)
						}
				}
			} else {
				v.bounds.size.width = width
				if hidden {
					hideView(v)
					v.position.x = -v.width / 2
                    self.dimView?.alpha = 0
				} else {
					v.shadowPathAutoSizeEnabled = false
					
					showView(v)
					v.position.x = width / 2
                    self.dimView?.alpha = 0.5
					v.shadowPathAutoSizeEnabled = true
				}
				layoutSubviews()
			}

		}
	}
	
	public func toggleLeftView(velocity: CGFloat = 0) {
		opened ? closeLeftView(velocity) : openLeftView(velocity)
	}
    
    var dimView: UIView? = nil

	public func openLeftView(velocity: CGFloat = 0) {
		if enabled {
			if let v: SideNavigationView = leftView {
				showView(v)
                
                if (dimView == nil) {
                    dimView?.removeFromSuperview()
                    dimView = UIView(frame: view.frame)
                    
                    dimView!.backgroundColor = UIColor.blackColor()
                    dimView!.alpha = 0.0
                    dimView!.userInteractionEnabled = false
                    view.addSubview(dimView!)
                    
                    dimView!.translatesAutoresizingMaskIntoConstraints = false
                    
                    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                        "|[dimView]|",
                        options: [],
                        metrics: nil,
                        views: ["dimView": dimView!]))
                    
                    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                        "V:|[dimView]|",
                        options: [],
                        metrics: nil,
                        views: ["dimView": dimView!]))
                    
                    UIView.animateWithDuration(0.5) { () -> Void in
                        self.dimView!.alpha = 0.5
                    }
     
                }
                
				UIView.animateWithDuration(Double(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(v.x / velocity)))), animations: {
                    v.position.x = v.width / 2
                })
			}
		}
	}
	
	public func closeLeftView(velocity: CGFloat = 0) {
		if enabled {
			if let v: SideNavigationView = leftView {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.dimView?.alpha = 0
                    }, completion: { (complete) -> Void in
                        self.dimView?.removeFromSuperview()
                        self.dimView = nil
                })
                
				UIView.animateWithDuration(Double(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(v.x / velocity)))),
					animations: {
						v.position.x = -v.width / 2
					}) { [unowned self] _ in
						self.hideView(v)
					}
			}
		}
	}
	
	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		if gestureRecognizer == panGesture {
			return opened || isPointContainedWithinLeftViewThreshold(touch.locationInView(view))
		}
		return opened && gestureRecognizer == tapGesture
	}
	
	@objc(handlePanGesture:)
	internal func handlePanGesture(recognizer: UIPanGestureRecognizer) {
		if enabled && (opened || isPointContainedWithinLeftViewThreshold(recognizer.locationInView(view))) {
			if let v: SideNavigationView = leftView {
				recognizer.locationInView(view)
				
				// Animate the panel.
				switch recognizer.state {
				case .Began:
					originalX = v.position.x
					
					showView(v)
				case .Changed:
					let w: CGFloat = v.width
					let translationX: CGFloat = recognizer.translationInView(v).x
					
					v.position.x = originalX + translationX > (w / 2) ? (w / 2) : originalX + translationX
				case .Ended, .Cancelled, .Failed:
					let p: CGPoint = recognizer.velocityInView(recognizer.view)
					let x: CGFloat = p.x >= 1000 || p.x <= -1000 ? p.x : 0
					
					if v.x <= -leftViewWidth + leftViewThreshold || x < -1000 {
						closeLeftView(x)
					} else {
						openLeftView(x)
					}
				case .Possible:
                    break
				}
			}
		}
	}
	
	@objc(handleTapGesture:)
	internal func handleTapGesture(recognizer: UITapGestureRecognizer) {
		if opened {
			if let v: SideNavigationView = leftView {
				if enabled && opened && !isPointContainedWithinView(v, point: recognizer.locationInView(v)) {
					closeLeftView()
				}
			}
		}
	}
	
	private func prepareView() {
		view.clipsToBounds = true
        
		prepareRootViewController()
        
		prepareLeftView()
		prepareLeftViewController()
        
		prepareGestures()
	}
	
	private func prepareRootViewController() {
		rootViewController.view.clipsToBounds = true
		rootViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		prepareViewControllerWithinContainer(rootViewController, container: view)
	}
	
	private func prepareLeftViewController() {
		if let v: SideNavigationView = leftView {
			leftViewController?.view.clipsToBounds = true
			leftViewController?.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
			prepareViewControllerWithinContainer(leftViewController, container: v)
		}
	}
	
	private func prepareLeftView() {
		if nil == leftViewController {
			enabled = false
		} else {
			leftViewWidth = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 280 : 320
			leftView = SideNavigationView()
			leftView!.frame = CGRectMake(0, 0, leftViewWidth, view.frame.height)
			leftView!.backgroundColor = UIColor.clearColor()
			view.addSubview(leftView!)
			
			leftView!.hidden = true
			leftView!.position.x = -leftViewWidth / 2
			leftView!.zPosition = 2000
		}
	}
    
	private func prepareViewControllerWithinContainer(viewController: UIViewController?, container: UIView) {
		if let v: UIViewController = viewController {
			addChildViewController(v)
			container.addSubview(v.view)
			container.sendSubviewToBack(v.view)
			v.didMoveToParentViewController(self)
		}
	}

	private func prepareGestures() {
		if nil == panGesture {
			panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
			panGesture!.delegate = self
			view.addGestureRecognizer(panGesture!)
		}
		
		if nil == tapGesture {
			tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
			tapGesture!.delegate = self
			tapGesture!.cancelsTouchesInView = false
			view.addGestureRecognizer(tapGesture!)
		}
	}

	private func removeGestures() {
		if let v: UIPanGestureRecognizer = panGesture {
			view.removeGestureRecognizer(v)
			panGesture = nil
		}
		if let v: UITapGestureRecognizer = tapGesture {
			view.removeGestureRecognizer(v)
			tapGesture = nil
		}
	}

	private func isPointContainedWithinLeftViewThreshold(point: CGPoint) -> Bool {
		return point.x <= leftViewThreshold
	}

	private func isPointContainedWithinView(container: UIView, point: CGPoint) -> Bool {
		return CGRectContainsPoint(container.bounds, point)
	}
	
	private func showView(container: SideNavigationView) {
		userInteractionEnabled = false
        container.layer.shadowOffset = CGSizeMake(0.2, 0.2)
        container.layer.shadowOpacity = 0.5
        container.layer.shadowRadius = 1
        container.layoutShadowPath()
		container.hidden = false
	}

	private func hideView(container: SideNavigationView) {
		userInteractionEnabled = true
        container.layer.shadowOffset = CGSizeZero
        container.layer.shadowOpacity = 0
        container.layer.shadowRadius = 0
        container.layoutShadowPath()
		container.hidden = true
	}
	
	private func layoutSubviews() {
		if let v: SideNavigationView = leftView {
			v.width = leftViewWidth
			v.height = view.bounds.height
			leftViewThreshold = nil == leftThreshold ? leftViewWidth / 2 : leftThreshold!
			if let vc: UIViewController = leftViewController {
				vc.view.frame.size.width = v.width
				vc.view.frame.size.height = v.height
				vc.view.center = CGPointMake(v.width / 2, v.height / 2)
			}
		}
	}
}