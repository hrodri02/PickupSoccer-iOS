//
//  CalendarViewCVCell.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class CalendarDateViewCVCell: UICollectionViewCell
{
    static let reuseIdentifier = String(describing: CalendarDateViewCVCell.self)
    
    var day: Day? {
        didSet {
            guard let day = day else { return }

            numberLabel.text = day.number
            accessibilityLabel = CalendarDateViewCVCell.accessibilityDateFormatter.string(from: day.date)
            updateSelectionStatus()
        }
    }
    
    private static let accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()
    
    private var widthAnchorConstraint: NSLayoutConstraint!
    
    private lazy var selectionBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemRed
        return view
    }()

    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = Colors.mainTextColor
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        isAccessibilityElement = true
        accessibilityTraits = .button
        contentView.addSubview(selectionBackgroundView)
        contentView.addSubview(numberLabel)
        setContstraintsForNumberLabel()
        setSelectionBackgroundViewConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateWSelectionBackgroundViewidthAnchorConstraint()
    }
    
    private func setContstraintsForNumberLabel() {
        NSLayoutConstraint.activate([
            numberLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            numberLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setSelectionBackgroundViewConstraints() {
        let size = traitCollection.horizontalSizeClass == .compact ?
                                                        min(min(frame.width, frame.height) - 10, 60) : 45
        
        widthAnchorConstraint = selectionBackgroundView.widthAnchor.constraint(equalToConstant: size)
        widthAnchorConstraint.isActive = true
        selectionBackgroundView.layer.cornerRadius = size / 2
        
        NSLayoutConstraint.activate([
          selectionBackgroundView.centerYAnchor.constraint(equalTo: numberLabel.centerYAnchor),
          selectionBackgroundView.centerXAnchor.constraint(equalTo: numberLabel.centerXAnchor),
          selectionBackgroundView.heightAnchor.constraint(equalTo: selectionBackgroundView.widthAnchor)
        ])
    }
    
    private func updateWSelectionBackgroundViewidthAnchorConstraint() {
        widthAnchorConstraint.isActive = false
        widthAnchorConstraint.constant = traitCollection.horizontalSizeClass == .compact ? min(min(frame.width, frame.height) - 10, 60) : 45
        widthAnchorConstraint.isActive = true
        selectionBackgroundView.layer.cornerRadius = widthAnchorConstraint.constant / 2
    }
}

// MARK: - Appearance
private extension CalendarDateViewCVCell {
    func updateSelectionStatus() {
        guard let day = day else { return }

        if day.isSelected {
            applySelectedStyle()
        } else {
            applyDefaultStyle(isWithinDisplayedMonth: day.isWithinDisplayedMonth)
        }
    }

    var isSmallScreenSize: Bool {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let smallWidth = UIScreen.main.bounds.width <= 350
        let widthGreaterThanHeight =
          UIScreen.main.bounds.width > UIScreen.main.bounds.height

        return isCompact && (smallWidth || widthGreaterThanHeight)
    }

    func applySelectedStyle() {
        accessibilityTraits.insert(.selected)
        accessibilityHint = nil

        numberLabel.textColor = isSmallScreenSize ? .systemRed : .white
        selectionBackgroundView.isHidden = isSmallScreenSize
    }

    func applyDefaultStyle(isWithinDisplayedMonth: Bool) {
        accessibilityTraits.remove(.selected)
        accessibilityHint = "Tap to select"

        numberLabel.textColor = isWithinDisplayedMonth ? Colors.mainTextColor : UIColor.darkGray
        selectionBackgroundView.isHidden = true
    }
}

