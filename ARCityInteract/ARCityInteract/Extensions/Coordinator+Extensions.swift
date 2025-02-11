//
//  Coordinator+Extensions.swift
//  ARCityInteract
//
//  Created by Vivek Jalahalli on 2/10/25.
//

import Foundation
import UIKit

/*
    Helper functions to create and style button
 */
extension Coordinator {
    
    func createButton(title: String, backgroundColor: UIColor, action: @escaping UIActionHandler) -> UIButton {
        let button = UIButton(configuration: .filled(), primaryAction: UIAction(handler: action))
        styleButton(button, title: title, backgroundColor: backgroundColor)
        return button
    }
    
    func styleButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
    }

}
