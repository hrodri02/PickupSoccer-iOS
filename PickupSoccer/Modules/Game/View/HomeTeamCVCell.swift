//
//  TeamCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/1/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class TeamCVCell: UICollectionViewCell
{
    static let verticalPaddingBeforeFirstImageView: CGFloat = SCREEN_HEIGHT * 0.10
    static let deltaXBetweenImageViews: CGFloat = 10.0
    var imageViews = [UIImageView]()
    var imageViewHeight: CGFloat {
        return (bounds.width - 5.0 * TeamCVCell.deltaXBetweenImageViews) / 4.0
    }
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = (bounds.height - imageViewHeight * 4.0 - 2 * TeamCVCell.verticalPaddingBeforeFirstImageView) / 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var goalieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1.0
        self.imageViews.append(imageView)
        imageView.alpha = 0.0
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let defenseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = TeamCVCell.deltaXBetweenImageViews
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let midFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = TeamCVCell.deltaXBetweenImageViews
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let forwardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = TeamCVCell.deltaXBetweenImageViews
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        goalieImageView.layer.cornerRadius = imageViewHeight / 2.0
        goalieImageView.clipsToBounds = true
        
        addImageViews(to: defenseStackView, count: 4, row: 1)
        addImageViews(to: midFieldStackView, count: 4, row: 2)
        addImageViews(to: forwardStackView, count: 2, row: 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addImageViews(to stackView: UIStackView, count: Int, row: Int) {
        /*
            row     i       tag
            1       0 - 3   1 - 4
            2       0 - 3   5 - 8
            3       0 - 1   9 - 10
         */
        for _ in 0 ..< count {
            let imageView = UIImageView()
            imageView.layer.borderWidth = 1.0
            imageView.layer.cornerRadius = imageViewHeight / 2.0
            imageView.clipsToBounds = true
            imageView.isUserInteractionEnabled = true
            imageView.alpha = 0.0
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
            stackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    func setBorderColorOfImageViews(color: UIColor) {
        for imageView in imageViews {
            imageView.layer.borderColor = color.cgColor
        }
    }
    
    func addSubviewsForHomeTeam() {
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(goalieImageView)
        verticalStackView.addArrangedSubview(defenseStackView)
        verticalStackView.addArrangedSubview(midFieldStackView)
        verticalStackView.addArrangedSubview(forwardStackView)
    }
    
    func addSubviewsForAwayTeam() {
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(forwardStackView)
        verticalStackView.addArrangedSubview(midFieldStackView)
        verticalStackView.addArrangedSubview(defenseStackView)
        verticalStackView.addArrangedSubview(goalieImageView)
    }
    
    func setConstraints() {
        setVerticalStackViewConstraints()
        setGoalieImageViewConstraints()
    }
    
    private func setVerticalStackViewConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: TeamCVCell.verticalPaddingBeforeFirstImageView),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: TeamCVCell.deltaXBetweenImageViews),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -TeamCVCell.deltaXBetweenImageViews),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -TeamCVCell.verticalPaddingBeforeFirstImageView)
        ])
    }
    
    private func setGoalieImageViewConstraints() {
        goalieImageView.widthAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
    }
}
