//
//  UINavigationControllerExtension.swift
//  Shari
//
//  Created by nakajijapan on 2015/12/11.
//  Copyright © 2015 nakajijapan. All rights reserved.
//

import UIKit

enum InternalStructureViewType:Int {
    case toView = 900, screenShot = 910, overlay = 920
}

public extension UINavigationController {

    public func parentTargetView() -> UIView {
        return self.view
    }
    
    func si_presentViewController(_ toViewController:UIViewController) {

        toViewController.beginAppearanceTransition(true, animated: true)
        ModalAnimator.present(toViewController.view, fromView: self.parentTargetView()) { [weak self] in
            guard let strongslef = self else { return }
            toViewController.endAppearanceTransition()
            toViewController.didMove(toParentViewController: strongslef)
            
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UINavigationController.overlayViewDidTap(_:)))
        let overlayView = ModalAnimator.overlayView(self.parentTargetView())
        overlayView!.addGestureRecognizer(tapGestureRecognizer)

    }
    
    func si_dismissModalView(_ completion: (() -> Void)?) {
        
        self.willMove(toParentViewController: nil)

        ModalAnimator.dismiss(
            self.parentTargetView(),
            presentingViewController: self.visibleViewController) { _ in

                completion?()

        }
        
    }
    
    func overlayViewDidTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        self.willMove(toParentViewController: nil)

        ModalAnimator.dismiss(
            self.parentTargetView(),
            presentingViewController: self.visibleViewController) { _ in


        }

    }
    
    func si_dismissDownSwipeModalView(_ completion: (() -> Void)?) {
        
        self.willMove(toParentViewController: nil)
        
        ModalAnimator.dismiss(
            self.view.superview ?? self.parentTargetView(),
            presentingViewController: self.visibleViewController) { _ in
                completion?()
        }
        
    }
}
