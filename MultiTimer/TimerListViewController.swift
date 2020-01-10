//
//  ViewController.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 11/12/2019.
//  Copyright © 2019 Bogdan Ignatev. All rights reserved.
//

import UIKit

class TimerListViewController: UIViewController {
    
    private let storage = TimerStorage()
    
    @IBOutlet private var timerList: UITableView!
    @IBOutlet private var messageLabel: UILabel!
    
    private var timers: [Timer] {
        get {
            return storage.timers
        }
        set {
            storage.timers = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage.delegate = self
        configureViews(with: timers.count)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTimer" {
            let addTimerViewController = segue.destination as! AddTimerViewController
            addTimerViewController.delegate = self
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        timerList.setEditing(editing, animated: animated)
    }
    
    @IBAction private func toggleMode() {
        setEditing(!isEditing, animated: true)
        let item = UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(toggleMode))
        navigationItem.leftBarButtonItem = item
    }
    
    private func configureViews(with timerCount: Int) {
        let displayTimerList = !(timerCount == 0)
        
        messageLabel.isHidden = displayTimerList
        timerList.isHidden = !displayTimerList
        navigationItem.leftBarButtonItem = displayTimerList ? editButtonItem : nil
        
        if !displayTimerList {
            setEditing(false, animated: false)
        }
    }
    
}

extension TimerListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        cell.timer = timers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        timers.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            timers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? TimerCell)?.timer = nil
    }
    
}

extension TimerListViewController: AddTimerViewControllerDelegate {
    
    func addTimerViewController(_ vc: AddTimerViewController, didFinishAddingTimer timer: Timer?) {
        if let timer = timer {
            timers.append(timer)
            timerList.insertRows(at: [IndexPath(row: timers.count - 1, section: 0)], with: .automatic)
        }
        
        dismiss(animated: true)
    }
    
}

extension TimerListViewController: TimerStorageDelegate {
    
    func timerStorage(_ storage: TimerStorage, timerCountDidChangeTo newCount: Int) {
        configureViews(with: newCount)
    }
    
}
