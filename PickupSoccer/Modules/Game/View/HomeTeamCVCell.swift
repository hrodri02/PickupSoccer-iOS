//
//  TeamCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 5/26/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class HomeTeamCVCell: UICollectionViewCell
{
    static let verticalPaddingBeforeFirstImageView: CGFloat = 20.0
    static let deltaXBetweenImageViews: CGFloat = 10.0
    
    var imageViewHeight: CGFloat {
        return (bounds.width - 5.0 * HomeTeamCVCell.deltaXBetweenImageViews) / 4.0
    }
    
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = (bounds.height - imageViewHeight * 4.0 - 2 * HomeTeamCVCell.verticalPaddingBeforeFirstImageView) / 3.0
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
        stackView.spacing = HomeTeamCVCell.deltaXBetweenImageViews
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let midFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = HomeTeamCVCell.deltaXBetweenImageViews
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let forwardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = HomeTeamCVCell.deltaXBetweenImageViews
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if let imageData = getSoccerPlayerImage() {
            goalieImageView.image = UIImage(data: imageData)
            goalieImageView.layer.cornerRadius = imageViewHeight / 2.0
            goalieImageView.clipsToBounds = true
            
            addImageViews(to: defenseStackView, count: 4, data: imageData)
            addImageViews(to: midFieldStackView, count: 4, data: imageData)
            addImageViews(to: forwardStackView, count: 2, data: imageData)
        }
        
        addSubviews()
        setVerticalStackViewConstraints()
        setGoalieImageViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getSoccerPlayerImage() -> Data? {
        if let imageURL = Bundle.main.url(forResource: "pexels-photo-5246967", withExtension: "jpeg") {
            do {
                let imageData = try Data(contentsOf: imageURL)
                return imageData
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
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
    
    private func addSubviews() {
        addSubview(verticalStackView)
        verticalStackView.addArrangedSubview(goalieImageView)
        verticalStackView.addArrangedSubview(defenseStackView)
        verticalStackView.addArrangedSubview(midFieldStackView)
        verticalStackView.addArrangedSubview(forwardStackView)
    }
    
    private func setVerticalStackViewConstraints() {
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: HomeTeamCVCell.verticalPaddingBeforeFirstImageView),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: HomeTeamCVCell.deltaXBetweenImageViews),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -HomeTeamCVCell.deltaXBetweenImageViews),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -HomeTeamCVCell.verticalPaddingBeforeFirstImageView)
        ])
    }
    
    
    private func setGoalieImageViewConstraints() {
        goalieImageView.widthAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
    }
}
