//
//  GameCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/3/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class GameCVCell: UICollectionViewCell {
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Place holder"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.5)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "May 7, 3:00 PM"
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "1 hr 30 min"
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.init(white: 1.0, alpha: 1.0)
        layer.cornerRadius = 5.0
        
        addSubview(locationLabel)
        addSubview(imageView)
        
        verticalStackView.addArrangedSubview(dateLabel)
        verticalStackView.addArrangedSubview(durationLabel)
        addSubview(verticalStackView)
        
        setLocationLabelConstraints()
        setImageViewConstraints()
        setVerticalStackViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLocationLabelConstraints() {
        NSLayoutConstraint.activate([
            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            locationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
        ])
    }
    
    private func setImageViewConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
    
    private func setVerticalStackViewConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            verticalStackView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5),
        ])
    }
}
