//
//  UIViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/25/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation

extension UIViewController {
    
    private enum Direction {
        case Right
        case Left
        case Top
        case Bottom
    }
    
    struct AssociatedKeys {
        static var presentedFromSide = "presentedFromSide"
        static var wasKeyboardShown = "wasKeyboardShown"
        static var fieldsToIgnore = "fieldsToIgnore"
    }
    
    //this lets us check to see if the item is supposed to be displayed or not
    var presentedFromSide: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.presentedFromSide) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.presentedFromSide, NSNumber(value: value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func dismissViewController(completion completion: (() -> Void)? = nil) {
        if presentedFromSide {
            dismissViewControllerToRight(completion: completion)
        } else {
            dismiss(animated: true, completion: completion)
        }
    }
    
    func dismissViewControllerToLeft(completion completion: (() -> Void)? = nil) {
        setupSlideOutToLeftTransition()
        self.dismiss(animated: true, completion: completion)
    }
    
    func dismissViewControllerToRight(completion completion: (() -> Void)? = nil) {
        setupSlideOutToRightTransition()
        self.dismiss(animated: true, completion: completion)
    }
    
    func presentViewControllerFromRight(viewControllerToPresent: UIViewController, completion: (() -> Void)? = nil) {
        viewControllerToPresent.presentedFromSide = true
        setupSlideInFromRightTransition()
        self.present(viewControllerToPresent, animated: true, completion: completion)
    }
    
    func setupSlideOutToTopTransition(){
        setupSlideTransition(direction: .Bottom)
    }
    
    func setupSlideOutToBottomTransition(){
        setupSlideTransition(direction: .Top)
    }
    
    func setupSlideOutToLeftTransition(){
        setupSlideTransition(direction: .Right)
    }
    
    func setupSlideOutToRightTransition(){
        setupSlideTransition(direction: .Left)
    }
    
    func setupSlideInFromRightTransition(){
        setupSlideTransition(direction: .Right)
    }
    
    private func setupSlideTransition(direction: Direction){
        let slideTransition = CATransition()
        slideTransition.duration = 0.7
        slideTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        slideTransition.type = kCATransitionPush
        
        switch direction {
        case .Left:
            slideTransition.subtype = kCATransitionFromLeft
        case .Right:
            slideTransition.subtype = kCATransitionFromRight
        case .Top:
            slideTransition.subtype = kCATransitionFromTop
        case .Bottom:
            slideTransition.subtype = kCATransitionFromBottom
        }
        
        self.view.window?.layer.add(slideTransition, forKey: nil)
    }
    
    func toggleBetweenViews(viewsToShow viewsToShow: [UIView], viewsToHide: [UIView], toLeft: Bool = true) {
        
        let transition = CATransition()
        transition.startProgress = 0
        transition.endProgress = 1.0
        transition.type = kCATransitionPush
        transition.subtype = toLeft ? kCATransitionFromRight :  kCATransitionFromLeft
        transition.duration = 0.5
        
        // Add the transition animation to both layers
        for v in viewsToShow {
            v.layer.add(transition, forKey: nil)
        }
        for v in viewsToHide {
            v.layer.add(transition, forKey: nil)
        }
        
        //toggle state
        for v in viewsToShow {
            v.isHidden = false
        }
        for v in viewsToHide {
            v.isHidden = true
        }
    }
}
