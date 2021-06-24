//
//  PositionTVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/18/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class PositionTVCell: UITableViewCell
{
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemTeal
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.init(white: 0.15, alpha: 1.0)
        textLabel?.textColor = UIColor.init(white: 0.9, alpha: 1.0)
        separatorInset = .zero
        
        addSubview(checkmarkImageView)
        NSLayoutConstraint.activate([
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with positionName: String, isSelected: Bool) {
        checkmarkImageView.isHidden = true
        
        textLabel?.text = positionName
        checkmarkImageView.isHidden = !isSelected
    }
}
