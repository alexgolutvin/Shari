//
//  ModalAnimator.swift
//  Shari
//
//  Created by nakajijapan on 2015/12/20.
//  Copyright © 2015 nakajijapan. All rights reserved.
//

import UIKit

open class ModalAnimator {
    
    open class func present(_ toView: UIView, fromView: UIView, completion: @escaping () -> Void) {
        
        let overlayView = UIView(frame: fromView.bounds)
        
        overlayView.backgroundColor = BackgroundColorOfOverlayView
        overlayView.isUserInteractionEnabled = true
        overlayView.tag = InternalStructureViewType.overlay.rawValue
        fromView.addSubview(overlayView)
        
        self.addScreenShotView(fromView, screenshotContainer: overlayView)

        var toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: fromView.bounds.size.height)
        toViewFrame.size.height = 0
        toView.frame = toViewFrame
        
        toView.tag = InternalStructureViewType.toView.rawValue
        fromView.addSubview(toView)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { () -> Void in
                
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                var toViewFrame = fromView.bounds.offsetBy(dx: 0, dy: statusBarHeight + fromView.bounds.size.height / 2.0)
                toViewFrame.size.height -= toViewFrame.origin.y
                toView.frame = toViewFrame
                
                toView.alpha = 1.0
                
            }, completion: { (result) -> Void in
                
                completion()
                
        }) 
        
    }
    
    open class func overlayView(_ fromView: UIView) -> UIView? {
        return fromView.viewWithTag(InternalStructureViewType.overlay.rawValue)
    }
    
    open class func modalView(_ fromView: UIView) -> UIView? {
        return fromView.viewWithTag(InternalStructureViewType.toView.rawValue)
    }
    
    open class func screenShotView(_ overlayView: UIView) -> UIImageView {
        return overlayView.viewWithTag(InternalStructureViewType.screenShot.rawValue) as! UIImageView
    }
    
   
    open class func dismiss(_ fromView: UIView, presentingViewController: UIViewController?, completion: @escaping () -> Void) {

        let targetView = fromView
        let modalView = ModalAnimator.modalView(fromView)
        let overlayView = ModalAnimator.overlayView(fromView)
        overlayView?.alpha = 1.0
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            
            modalView?.frame = CGRect(
                x: (targetView.bounds.size.width - modalView!.frame.size.width) / 2.0,
                y: targetView.bounds.size.height,
                width: (modalView?.frame.size.width)!,
                height: (modalView?.frame.size.height)!);
            
            }, completion: { (result) -> Void in
                
                overlayView?.removeFromSuperview()
                modalView?.removeFromSuperview()
                
                // Remove Modal View Controller
                presentingViewController?.removeFromParentViewController()
        }) 
        
        // Begin Overlay Animation
        if overlayView != nil {
            
            let screenShotView = overlayView?.subviews[0] as! UIImageView
            screenShotView.layer.add(self.animationGroupForward(false), forKey: "bringForwardAnimation")
            
            UIView.animate(withDuration: 0.6, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            
                    screenShotView.alpha = 1.0
                
                }, completion: { (result) -> Void in

                    completion()

            })
            
        }
   
    }
    
    open class func transitionBackgroundView(_ overlayView: UIView, location:CGPoint) {
        
        let screenShotView = ModalAnimator.screenShotView(overlayView)
        let scale = self.map(location.y, inMin: 0, inMax: UIScreen.main.bounds.height, outMin: 0.9, outMax: 1.0)
        let transform = CATransform3DMakeScale(scale, scale, 1)
        screenShotView.layer.removeAllAnimations()
        screenShotView.layer.transform = transform
        screenShotView.setNeedsLayout()
        screenShotView.layoutIfNeeded()
        
    }
    
    // MARK - Private
    
    class func addScreenShotView(_ capturedView: UIView, screenshotContainer:UIView) {
        
        screenshotContainer.isHidden = true
        
        UIGraphicsBeginImageContextWithOptions(capturedView.bounds.size, true, UIScreen.main.scale)
        capturedView.drawHierarchy(in: capturedView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        screenshotContainer.isHidden = false
        
        let screenshot = UIImageView(image: image)
        screenshot.tag = InternalStructureViewType.screenShot.rawValue
        screenshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        screenshotContainer.addSubview(screenshot)
        
        screenshot.layer.add(self.animationGroupForward(true), forKey:"pushedBackAnimation")
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            screenshot.alpha = 0.5
        }) 
        

    }
    
    class func animationGroupForward(_ forward:Bool) -> CAAnimationGroup {

        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, 0.95, 0.95, 1)
        
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "transform")
        
        if forward {
            animation.toValue = NSValue(caTransform3D:transform)
        } else {
            animation.toValue = NSValue(caTransform3D:CATransform3DIdentity)
        }
        
        let duration:CFTimeInterval = 1.0
        animation.duration = duration / 3.0
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
        
        let group = CAAnimationGroup()
        group.fillMode = kCAFillModeForwards
        group.isRemovedOnCompletion = false
        group.duration = animation.duration
        
        group.animations = [animation]
        return group
    }


    class func map(_ value:CGFloat, inMin:CGFloat, inMax:CGFloat, outMin:CGFloat, outMax:CGFloat) -> CGFloat {
        
        let inRatio = value / (inMax - inMin)
        let outRatio = (outMax - outMin) * inRatio + outMin

        return outRatio
    }

    
}
