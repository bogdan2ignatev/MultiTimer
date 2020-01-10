//
//  timers.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 30/12/2019.
//  Copyright © 2019 Bogdan Ignatev. All rights reserved.
//

import Foundation

protocol TimerStorageDelegate: class {
    func timerStorage(_ storage: TimerStorage, timerCountDidChangeTo newCount: Int)
}

class TimerStorage {
    
    var timers: [Timer] = {
        guard let url = TimerStorage.fileURL, let data = try? Data(contentsOf: url) else {
            return []
        }
        
        let timers = try? PropertyListDecoder().decode([Timer].self, from: data)
        return timers ?? []
      
        }()  {
        didSet {
            saveTimers()
            if timers.count != oldValue.count {
                delegate?.timerStorage(self, timerCountDidChangeTo: timers.count)
            }
        }
    }
    weak var delegate: TimerStorageDelegate?
    
    private static var fileURL: URL? {
        guard let dirURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return dirURL.appendingPathComponent("timers.plist")
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(saveTimers), name: .timerStateDidSet, object: nil)
    }
    
    @objc private func saveTimers() {
        guard let data = try? PropertyListEncoder().encode(timers) else {
            return
        }
        
        guard let url = TimerStorage.fileURL else {
            return
        }
        
        try? data.write(to: url)
        
    }
    
}
    

