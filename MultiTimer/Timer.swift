//
//  Timer.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 08/01/2020.
//  Copyright © 2020 Bogdan Ignatev. All rights reserved.
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let timerStateDidSet = Notification.Name("timerStateDidSet")
}

class Timer {
    
    enum State {
        case stopped
        case running
        case paused
    }
    
    private enum InnerState {
        case stopped
        case running(destinationTimePoint: TimeInterval)
        case paused(remainingTimeDifference: TimeInterval)
    }
    
    let name: String
    let identifier: String
    
    private let initialTimeDifference: TimeInterval
    
    var initialTime: TimeInterval {
        return initialTimeDifference
    }
    
    var timeForState: TimeInterval {
        updateInnerState()
        switch innerState {
        case .stopped:
            return initialTimeDifference
        case .running(let destinationTimePoint):
            return destinationTimePoint - Timer.currentTimePoint
        case .paused(let remainingTimeDifference):
            return remainingTimeDifference
        }
    }
    
    var state: State {
        get {
            updateInnerState()
            switch innerState {
            case .stopped:
                return .stopped
            case .running:
                return .running
            case .paused:
                return .paused
            }
        }
        set {
            switch newValue {
            case .stopped:
                innerState = .stopped
                removeNotification()
            case .running:
                let timeDifference: TimeInterval
                if case .paused(let remainingTimeDifference) = innerState {
                    timeDifference = remainingTimeDifference
                } else {
                    timeDifference = initialTimeDifference
                }
                let destinationTimePoint = Timer.currentTimePoint + timeDifference
                innerState = .running(destinationTimePoint: destinationTimePoint)
                addNotification()
            case .paused:
                if case .running(let destinationTimePoint) = innerState {
                    innerState = .paused(remainingTimeDifference: destinationTimePoint - Timer.currentTimePoint)
                }
                removeNotification()
            }
            
        }
    }
    
    private static var currentTimePoint: TimeInterval {
        return Date.timeIntervalSinceReferenceDate
    }
    
    private var innerState: InnerState = .stopped {
        didSet {
            NotificationCenter.default.post(name: .timerStateDidSet, object: nil)
        }
    }
    
    init(name: String, time initialTimeDifference: TimeInterval) {
        if initialTimeDifference <= 0 {
            fatalError("Time must be greater than 0")
        }
        
        self.name = name
        self.initialTimeDifference = initialTimeDifference
        self.identifier = UUID().uuidString
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        initialTimeDifference = try values.decode(TimeInterval.self, forKey: .initialTimeDifference)
        if initialTimeDifference <= 0 {
            fatalError("Time must be greater than 0")
        }
        
        name = try values.decode(String.self, forKey: .name)
        identifier = try values.decode(String.self, forKey: .identifier)
        
        let destinationTimePoint = try values.decode(TimeInterval?.self, forKey: .destinationTimePoint)
        
        if let point = destinationTimePoint {
            if point > Timer.currentTimePoint {
                innerState = .running(destinationTimePoint: point)
            }
        } else {
            let remainingTimeDifference = try values.decode(TimeInterval?.self, forKey: .remainingTimeDifference)
            if let difference = remainingTimeDifference {
                innerState = .paused(remainingTimeDifference: difference)
            }
        }
    }
    
    deinit {
        removeNotification()
    }
    
    private func updateInnerState() {
        switch innerState {
        case .running(let destinationTimePoint):
            if destinationTimePoint + 1 < Timer.currentTimePoint {
                innerState = .stopped
            }
        default: break
        }
    }
    
}

extension Timer: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case initialTimeDifference
        case identifier
        case destinationTimePoint
        case remainingTimeDifference
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(initialTimeDifference, forKey: .initialTimeDifference)
        try container.encode(identifier, forKey: .identifier)
        
        
        var destinationTimePoint: TimeInterval?
        var remainingTimeDifference: TimeInterval?
        
        switch innerState {
        case .stopped:
            break
        case .running(let point):
            destinationTimePoint = point
        case .paused(let difference):
            remainingTimeDifference = difference
        }
        
        try container.encode(destinationTimePoint, forKey: .destinationTimePoint)
        try container.encode(remainingTimeDifference, forKey: .remainingTimeDifference)
    }
    
}

extension Timer {
    
    private func addNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(initialTime.hmsString) \(name)"
        content.sound = .defaultCritical
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeForState, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
}

