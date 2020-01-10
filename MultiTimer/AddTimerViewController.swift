//
//  AddTimerViewController.swift
//  MultiTimer
//
//  Created by Bogdan Ignatev on 12/12/2019.
//  Copyright © 2019 Bogdan Ignatev. All rights reserved.
//

import UIKit

protocol AddTimerViewControllerDelegate: class {
    func addTimerViewController(_ vc: AddTimerViewController, didFinishAddingTimer timer: Timer?)
}

class AddTimerViewController: UIViewController {
    
    private let timePickerComponents = [24, 60, 60]
    
    weak var delegate: AddTimerViewControllerDelegate!
    
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var timePicker: UIPickerView!
    
    private var selectedTime: TimeInterval {
        let hours = timePicker.selectedRow(inComponent: 0)
        let minutes = timePicker.selectedRow(inComponent: 1)
        let seconds = timePicker.selectedRow(inComponent: 2)
        
        return TimeInterval(withHours: hours, minutes: minutes, seconds: seconds)
    }
    
    @IBAction private func hideKeyboardOrScreen() {
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        } else {
            delegate.addTimerViewController(self, didFinishAddingTimer: nil)
        }
        
    }
    
    @IBAction private func addTimer() {
        if selectedTime > 0 {
            let timer = Timer(name: nameTextField.text!, time: selectedTime)
            delegate.addTimerViewController(self, didFinishAddingTimer: timer)
        }
    }
    

}

extension AddTimerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return timePickerComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timePickerComponents[component]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let unit: String
        switch component {
        case 0:
            unit = NSLocalizedString("hours", comment: "pickerView(_:titleForRow:forComponent:)")
        case 1:
            unit = NSLocalizedString("min", comment: "pickerView(_:titleForRow:forComponent:)")
        case 2:
            unit = NSLocalizedString("sec", comment: "pickerView(_:titleForRow:forComponent:)")
        default:
            fatalError("Mustn't get there")
        }
        
        return "\(row) \(unit)"
    }
    
}
