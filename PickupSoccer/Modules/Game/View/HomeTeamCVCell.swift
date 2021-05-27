//
//  TeamCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/26/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class TeamCVCell: UICollectionViewCell
{
    var imageViewHeight: CGFloat {
        return (bounds.width - 50.0) / 4.0
    }
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = (bounds.height - imageViewHeight * 4.0 - 40.0) / 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var goalieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let defenseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let midFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let forwardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let imageURL = Bundle.main.url(forResource: "pexels-photo-5246967", withExtension: "jpeg") {
            do {
                let imageData = try Data(contentsOf: imageURL)
                goalieImageView.image = UIImage(data: imageData)
                goalieImageView.layer.cornerRadius = imageViewHeight / 2.0
                goalieImageView.clipsToBounds = true
                
                addImageViews(to: defenseStackView, count: 4, data: imageData)
                addImageViews(to: midFieldStackView, count: 4, data: imageData)
                addImageViews(to: forwardStackView, count: 2, data: imageData)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(goalieImageView)
        verticalStackView.addArrangedSubview(defenseStackView)
        verticalStackView.addArrangedSubview(midFieldStackView)
        verticalStackView.addArrangedSubview(forwardStackView)
        setVerticalStackViewConstraints()
        setGoalieImageViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addImageViews(to stackView: UIStackView, count: Int, data: Data) {
        for _ in 0 ..< count {
            let image = UIImage(data: data)
            let imageView = UIImageView(image: image)
            imageView.layer.cornerRadius = imageViewHeight / 2.0
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
            stackView.addArrangedSubview(imageView)
        }
    }
    
    private func setVerticalStackViewConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    
    private func setGoalieImageViewConstraints() {
        goalieImageView.widthAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
    }
}
