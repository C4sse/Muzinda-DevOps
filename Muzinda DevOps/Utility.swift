//
//  Utility.swift
//  Muzinda DevOps
//
//  Created by Casse on 7/5/2019.
//  Copyright © 2019 Casse. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
}

extension UIView {
    
    public enum Animation {
        case left
        case right
        case none
    }
    
    func slideIn(from edge: Animation = .none, x: CGFloat = 0, y: CGFloat = 0, duration: TimeInterval = 0.7, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) -> UIView {
        
        let offset = offsetFor(edge: edge)
        transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        isHidden = false
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            
            self.transform = .identity
            self.alpha = 1
            
        }, completion: completion)
        
        return self
    }
    
    func slideOut(from edge: Animation = .none, x: CGFloat = 0, y: CGFloat = 0, duration: TimeInterval = 0.7, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) -> UIView {
        
        let offset = offsetFor(edge: edge)
        let endTransform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            
            self.transform = endTransform
            self.alpha = 1
            
        }, completion: completion)
        
        return self
    }
    
    func offsetFor(edge: Animation) -> CGPoint {
        
        if let size = self.superview?.frame.size {
            
            switch edge {
            case .none: return CGPoint.zero
            case .left: return CGPoint(x: -frame.maxX, y: 0)
            case .right: return CGPoint(x: size.width - frame.minX, y: 0)
            }
        }
        return .zero
    }
}
