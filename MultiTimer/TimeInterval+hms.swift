//
//  TimeInterval+hms.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 11/12/2019.
//  Copyright © 2019 Bogdan Ignatev. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    var hms: (hours: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self)
        let hours = seconds / 3600
        seconds -= hours * 3600
        let minutes = seconds / 60
        seconds -= minutes * 60
        
        return (hours, minutes, seconds)
    }
    
    var hmsString: String {
        let (h, m, s) = hms
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
    init(withHours hours: Int, minutes: Int, seconds: Int) {
        self = TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
    
}
