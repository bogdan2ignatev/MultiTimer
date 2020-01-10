//
//  UIView+safelySetIsHidden.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 25/12/2019.
//  Copyright © 2019 Bogdan Ignatev. All rights reserved.
//

import UIKit

extension UIView {
    
    // This avoids the UIStackView bug related with assigning subview's isHidden property the same value
    func safelySetIsHidden(_ flag: Bool) {
        if isHidden != flag {
            isHidden.toggle()
        }
    }
    
}
