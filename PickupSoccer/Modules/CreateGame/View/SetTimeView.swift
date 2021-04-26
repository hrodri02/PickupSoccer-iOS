//
//  SetTimeView.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/19/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class SetTimeView: UIView
{
    private let NUM_DUP_DATASETS = 200
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textColor = Colors.mainTextColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var hourMinPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(12 * NUM_DUP_DATASETS / 2, inComponent: 0, animated: false)
        picker.selectRow(60 * NUM_DUP_DATASETS / 2, inComponent: 1, animated: false)
        picker.layer.borderWidth = 1.0
        picker.layer.borderColor = UIColor.systemTeal.cgColor
        picker.layer.cornerRadius = 5.0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let amPmSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["AM", "PM"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.systemTeal
        segmentedControl.addTarget(self, action: #selector(amPmSegmentedControlValueChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let startTimeChangedCompletionHandler: ((Int, Int) -> Void)
    
    init(text: String, startTimeChangedCompletionHandler: @escaping (Int, Int) -> ()) {
        self.startTimeChangedCompletionHandler = startTimeChangedCompletionHandler
        super.init(frame: CGRect.zero)
        label.text = text
        
        addSubviews()
        setLabelConstraints()
        setHourMinPickerConstraints()
        setAmPmSegmentedControlConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func amPmSegmentedControlValueChanged(sender: UISegmentedControl) {
        let (hour, min) = getSelectedTimeInHourMinAmPm()
        startTimeChangedCompletionHandler(hour, min)
    }
    
    public func getSelectedTimeInHourMinAmPm() -> (Int, Int) {
        var hour = hourMinPicker.selectedRow(inComponent: 0) % 12 + 1
        let min = hourMinPicker.selectedRow(inComponent: 1) % 60
        let isPmSelected = amPmSegmentedControl.selectedSegmentIndex == 1
        let isAmSelected = amPmSegmentedControl.selectedSegmentIndex == 0
        
        if (isPmSelected && hour < 12) || (isAmSelected && hour == 12) {
            hour += 12
        }
        
        return (hour, min)
    }
    
    private func addSubviews() {
        addSubview(label)
        addSubview(hourMinPicker)
        addSubview(amPmSegmentedControl)
    }
    
    private func setLabelConstraints() {
        let width = label.intrinsicContentSize.width
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    private func setHourMinPickerConstraints() {
        NSLayoutConstraint.activate([
            hourMinPicker.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            hourMinPicker.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.85),
            hourMinPicker.trailingAnchor.constraint(equalTo: amPmSegmentedControl.leadingAnchor, constant: -10),
            hourMinPicker.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setAmPmSegmentedControlConstraints() {
        let width = amPmSegmentedControl.intrinsicContentSize.width
        NSLayoutConstraint.activate([
            amPmSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            amPmSegmentedControl.heightAnchor.constraint(equalTo: label.heightAnchor),
            amPmSegmentedControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            amPmSegmentedControl.widthAnchor.constraint(equalToConstant: width)
        ])
    }
}

extension SetTimeView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return NUM_DUP_DATASETS * 12
        }
        return NUM_DUP_DATASETS * 60
    }
}

extension SetTimeView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = UIColor.systemTeal
        label.textAlignment = .center
        if component == 0 {
            let hour = (row % 12) + 1
            label.text = "\(hour)"
        }
        else {
            let min = row % 60
            label.text = "\(min)"
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let (hour, min) = getSelectedTimeInHourMinAmPm()
        startTimeChangedCompletionHandler(hour, min)
    }
}
