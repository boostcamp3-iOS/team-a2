//
//  UIColor+NamedColor.swift
//  OneDay
//
//  Created by juhee on 25/01/2019.
//  Copyright © 2019 teamA2. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var doBlue: UIColor {
        return UIColor(named: "doBlue")!
    }
    static var doDark: UIColor {
        return UIColor(named: "doDark")!
    }
    static var doGray: UIColor {
        return UIColor(named: "doGray")!
    }
    
    static var doLight: UIColor {
        return UIColor(named: "doLight")!
    }
    
    static var calendarBackgroundColor: UIColor {
        return UIColor(red: CGFloat(239/255.0), green: CGFloat(239/255.0), blue: CGFloat(245/255.0), alpha: CGFloat(1.0))
    }

}
