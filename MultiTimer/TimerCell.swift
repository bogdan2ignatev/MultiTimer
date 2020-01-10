//
//  TimerCell.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 11/12/2019.
//  Copyright © 2019 Bogdan Ignatev. All rights reserved.
//

import UIKit

class TimerCell: UITableViewCell {
    
    @IBInspectable var defaultBackgroundColor: UIColor = .white
    @IBInspectable var runningBackgroundColor: UIColor = .white
    @IBInspectable var pausedBackgroundColor: UIColor = .white

    @IBInspectable var animationDuration: Double = 0
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
    weak var timer: Timer? {
        didSet {
            guard let timer = timer else {
                updater?.invalidate()
                return
            }
            
            if case .running = timer.state {
                startUpdater()
            }
            
            configure(animated: false)
        }
    }
    
    private weak var updater: Foundation.Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("*** \(Date()) setEditing(\(editing), animated: \(animated)) (timer?.name: \(timer?.name))")
        super.setEditing(editing, animated: animated)
        configure(animated: animated)
    }
    
    func configure(animated: Bool = true) {
        guard let timer = timer else {
            return
        }
        
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            guard !self.isEditing else {
                self.timeLabel.text = timer.initialTime.hmsString
                
                self.startButton.safelySetIsHidden(true)
                self.pauseButton.safelySetIsHidden(true)
                self.stopButton.safelySetIsHidden(true)
                
                self.backgroundColor = self.defaultBackgroundColor
                
                return
            }
            
            self.timeLabel.text = ceil(timer.timeForState).hmsString
            self.nameLabel.text = timer.name
            
            switch timer.state {
            case .stopped:
                self.stopButton.safelySetIsHidden(true)
                self.pauseButton.safelySetIsHidden(true)
                
                self.startButton.safelySetIsHidden(false)
                
                self.backgroundColor = self.defaultBackgroundColor
            case .running:
                self.startButton.safelySetIsHidden(true)
                
                self.stopButton.safelySetIsHidden( ceil(timer.timeForState) == 0 ? true : false )
                self.pauseButton.safelySetIsHidden( ceil(timer.timeForState) == 0 ? true : false )
                
                self.backgroundColor = self.runningBackgroundColor
            case .paused:
                self.pauseButton.safelySetIsHidden(true)
                
                self.startButton.safelySetIsHidden(false)
                self.stopButton.safelySetIsHidden(false)
                
                self.backgroundColor = self.pausedBackgroundColor
            }
        }
    }
    
    @IBAction private func startTimer() {
        timer?.state = .running
        configure()
        startUpdater()
    }
    
    @IBAction private func pauseTimer() {
        timer?.state = .paused
        configure()
    }
    
    @IBAction private func stopTimer() {
        timer?.state = .stopped
        configure()
    }
    
    private func startUpdater() {
        guard let timer = timer else {
            return
        }
        let date = Date(timeIntervalSinceNow: timer.timeForState.truncatingRemainder(dividingBy: 1))
        let updater = Foundation.Timer(fire: date, interval: 1, repeats: true) {
            [weak timer] updater in
            self.configure()
            if timer?.state != .running {
                updater.invalidate()
            }
        }
        self.updater = updater
        RunLoop.main.add(updater, forMode: .common)
    }

    
}

