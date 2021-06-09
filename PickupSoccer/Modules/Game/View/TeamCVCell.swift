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
    var newPositionSelected: ((Position) -> ())?
    static let verticalPaddingBeforeFirstImageView: CGFloat = 20.0
    static let deltaXBetweenImageViews: CGFloat = 10.0
    var imageViews = [UIImageView]()
    var soccerPlayerImageData: Data?
    var imageViewHeight: CGFloat {
        return (bounds.width - 5.0 * TeamCVCell.deltaXBetweenImageViews) / 4.0
    }
    
    var positionToIndex: [Position : Int] {
        return [:]
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
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:))))
        imageView.backgroundColor = UIColor.black
        self.imageViews.append(imageView)
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
        
        addSubviews()
        setVerticalStackViewConstraints()
        setGoalieImageViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with players: [User : Position], newPositionSelected: @escaping (Position) -> Void) {
        self.newPositionSelected = newPositionSelected
        
        for imageView in imageViews {
            imageView.image = nil
        }
        
        let imageData = getSoccerPlayerImage()
        for (_, position) in players {
            if let data = imageData, let index = positionToIndex[position] {
                imageViews[index].image = UIImage(data: data)
            }
        }
    }
    
    @objc func didTapImageView(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        
        var positionSelected: Position = .none
        for (position, index) in positionToIndex {
            let currImageView = imageViews[index]
            if currImageView == imageView {
                positionSelected = position
                break
            }
        }
        if let newPositionSelected = newPositionSelected {
            newPositionSelected(positionSelected)
        }
    }
    
    private func getSoccerPlayerImage() -> Data? {
        if let imageURL = Bundle.main.url(forResource: "pexels-photo-5246967", withExtension: "jpeg") {
            do {
                let imageData = try Data(contentsOf: imageURL)
                soccerPlayerImageData = imageData
                return imageData
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
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
            imageView.backgroundColor = UIColor.black
            imageView.layer.cornerRadius = imageViewHeight / 2.0
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:))))
            imageView.widthAnchor.constraint(equalToConstant: imageViewHeight).isActive = true
            stackView.addArrangedSubview(imageView)
            imageViews.append(imageView)
        }
    }
    
    func addSubviews() {
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
