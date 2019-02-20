//
//  UIViewController+CATransition.swift
//  OneDay
//
//  Created by juhee on 20/02/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addFadeTransition(duration: CFTimeInterval = 0.2) {
        
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
    }
}
