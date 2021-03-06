//
//  NavigationController.swift
//  Shari
//
//  Created by nakajijapan on 2015/12/14.
//  Copyright © 2015 nakajijapan. All rights reserved.
//

import UIKit

@objc public protocol NavigationControllerDelegate {
    @objc optional func navigationControllerDidSpreadToEntire(_ navigationController: UINavigationController)
}


open class NavigationController: UINavigationController, UIGestureRecognizerDelegate {

    open var si_delegate: NavigationControllerDelegate?
    open var parentNavigationController: UINavigationController?
    
    open var minDeltaUpSwipe: CGFloat = 50
    open var minDeltaDownSwipe: CGFloat = 50
    
    open var dismissControllSwipeDown = false
    open var fullScreenSwipeUp = true
    
    var previousLocation = CGPoint.zero
    var originalLocation = CGPoint.zero
    var originalFrame = CGRect.zero
    
    deinit{
        parentNavigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override open func viewDidLoad() {
        parentNavigationController?.interactivePopGestureRecognizer?.delegate = self
        originalFrame = self.view.frame
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(NavigationController.handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
   
    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let
            parentView = parent?.view,
            let parentTargetView = parentNavigationController?.parentTargetView(),
            let backgroundView = ModalAnimator.overlayView(parentTargetView)
        else {
            return
        }
        
        let location = gestureRecognizer.location(in: parentView)
        let degreeY = location.y - self.previousLocation.y

        switch gestureRecognizer.state {
        case UIGestureRecognizerState.began :
            
            originalLocation = self.view.frame.origin
            break

        case UIGestureRecognizerState.changed :
            
            var frame = self.view.frame
            frame.origin.y += degreeY
            frame.size.height += -degreeY
            self.view.frame = frame

            ModalAnimator.transitionBackgroundView(backgroundView, location: location)

            break

        case UIGestureRecognizerState.ended :
            
            if fullScreenSwipeUp &&  originalLocation.y - self.view.frame.minY > minDeltaUpSwipe {
                
                UIView.animate(
                    withDuration: 0.2,
                    animations: { [weak self] in
                        guard let strongslef = self else { return }
                        
                        var frame = strongslef.originalFrame
                        let statusBarHeight = UIApplication.shared.statusBarFrame.height
                        frame.origin.y = statusBarHeight
                        frame.size.height -= statusBarHeight
                        strongslef.view.frame = frame
                        
                        ModalAnimator.transitionBackgroundView(backgroundView, location: strongslef.view.frame.origin)
                        
                    }, completion: { (result) -> Void in
                        
                        UIView.animate(
                            withDuration: 0.1,
                            delay: 0.0,
                            options: UIViewAnimationOptions.curveLinear,
                            animations: { () -> Void in
                                backgroundView.alpha = 0.0
                            },
                            completion: { [weak self] result in
                                guard let strongslef = self else { return }
                              
                                gestureRecognizer.isEnabled = false
                                strongslef.si_delegate?.navigationControllerDidSpreadToEntire?(strongslef)
                                
                            }
                        )
                    }
                )
                
            } else if dismissControllSwipeDown && self.view.frame.minY - originalLocation.y > minDeltaDownSwipe {
                parentNavigationController?.si_dismissDownSwipeModalView(nil)
            } else {

                UIView.animate(
                    withDuration: 0.6,
                    delay: 0.0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.1,
                    options: UIViewAnimationOptions.curveLinear,
                    animations: { [weak self] in
                        guard let strongslef = self else { return }
                        
                        ModalAnimator.transitionBackgroundView(backgroundView, location: strongslef.originalLocation)
                        
                        var frame = strongslef.originalFrame //view.frame
                        frame.origin.y = strongslef.originalLocation.y
                        frame.size.height -= strongslef.originalLocation.y
                        strongslef.view.frame = frame
                    },

                    completion: { (result) -> Void in

                        gestureRecognizer.isEnabled = true

                })
                
            }

            break

        default:
            break
            
        }
        
        self.previousLocation = location
        
    }
    
}
