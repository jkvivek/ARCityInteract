//
//  UIColor+Extensions.swift
//  ARCityInteract
//
//  Created by Vivek Jalahalli on 2/10/25.
//

import Foundation
import UIKit

/*
    extention to help in creating random UIColor
 */
extension UIColor {

    static func random() -> UIColor {
        UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
}
