//
//  GameDetailsFooterView.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 3/14/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameDetailsFooterView : UIView
{
    let cancelGameLocationButtonTapped: (() -> Void)
    let confirmGameLocationButtonTapped: (() -> Void)
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = UIColor.systemBlue
        cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 5.0
        cancelButton.backgroundColor = UIColor.white
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
        
    
    lazy var confirmButton: UIButton = {
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.tintColor = Colors.mainTextColor
        confirmButton.backgroundColor = UIColor.systemBlue
        confirmButton.layer.cornerRadius = 5.0
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        return confirmButton
    }()
    
    init(frame: CGRect, cancelGameLocationButtonTapped: @escaping (() -> Void), confirmGameLocationButtonTapped: @escaping (() -> Void)) {
        self.cancelGameLocationButtonTapped = cancelGameLocationButtonTapped
        self.confirmGameLocationButtonTapped = confirmGameLocationButtonTapped
        super.init(frame: frame)
        addSubviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(lineView)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 0.5),
            
            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            cancelButton.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -5),
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            confirmButton.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 5),
            confirmButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            confirmButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            confirmButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
    }
    
    @objc func cancelButtonTapped() {
        cancelGameLocationButtonTapped()
    }
    
    @objc func confirmButtonTapped() {
        confirmGameLocationButtonTapped()
    }
}
