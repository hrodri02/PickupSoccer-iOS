//
//  CalendarPickerFooterView.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 2/15/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

protocol CalendarPickerFooterViewDelegate: AnyObject {
    func didTapPrevOrNextMonthButton(_ newBaseDate: Date)
}

class CalendarPickerFooterView: UIView {
    weak var delegate: CalendarPickerFooterViewDelegate?
    
    var baseDate = Date() {
      didSet {
        updatePrevButton()
        updateNextButton()
      }
    }
    
  lazy var separatorView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
    
    lazy var prevMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textAlignment = .right

        if let chevronImage = UIImage(systemName: "chevron.left.circle.fill") {
        let imageAttachment = NSTextAttachment(image: chevronImage)
        let attributedString = NSMutableAttributedString()
        attributedString.append(
          NSAttributedString(attachment: imageAttachment)
        )
        attributedString.append(
          NSAttributedString(string: " Prev")
        )

        button.setAttributedTitle(attributedString, for: .normal)
        } else {
        button.setTitle("Prev", for: .normal)
        }

        button.titleLabel?.textColor = Colors.mainTextColor
        button.addTarget(self, action: #selector(didTapPrevMonthButton), for: .touchUpInside)
        return button
    }()

  lazy var nextMonthButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    button.titleLabel?.textAlignment = .right

    if let chevronImage = UIImage(systemName: "chevron.right.circle.fill") {
      let imageAttachment = NSTextAttachment(image: chevronImage)
      let attributedString = NSMutableAttributedString(string: "Next ")

      attributedString.append(
        NSAttributedString(attachment: imageAttachment)
      )

      button.setAttributedTitle(attributedString, for: .normal)
    } else {
      button.setTitle("Next", for: .normal)
    }

    button.titleLabel?.textColor = Colors.mainTextColor

    button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
    return button
  }()
  

    init(delegate: CalendarPickerFooterViewDelegate? = nil) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.init(white: 0.2, alpha: 0.80)

        addSubview(separatorView)
        addSubview(prevMonthButton)
        addSubview(nextMonthButton)
    }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  private var previousOrientation: UIDeviceOrientation = UIDevice.current.orientation

  override func layoutSubviews() {
    super.layoutSubviews()

    let smallDevice = UIScreen.main.bounds.width <= 350

    let fontPointSize: CGFloat = smallDevice ? 14 : 17

    prevMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
    nextMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)

    NSLayoutConstraint.activate([
      separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
      separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
      separatorView.topAnchor.constraint(equalTo: topAnchor),
      separatorView.heightAnchor.constraint(equalToConstant: 1),

      prevMonthButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      prevMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor),

      nextMonthButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      nextMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor),
    ])
  }
    
    public func setPrevMonthButtonEnabled(_ enabled: Bool) {
        prevMonthButton.isEnabled = enabled
    }
    
    @objc func didTapPrevMonthButton() {
        updateBaseDateByAdding(month: -1)
        delegate?.didTapPrevOrNextMonthButton(baseDate)
//        didTapNextOrPrevMonthCompletionHandler(baseDate)
    }

    @objc func didTapNextMonthButton() {
        updateBaseDateByAdding(month: 1)
//        didTapNextOrPrevMonthCompletionHandler(baseDate)
        delegate?.didTapPrevOrNextMonthButton(baseDate)
    }
    
    func updateBaseDateByAdding(month: Int) {
        self.baseDate = Calendar.current.date(byAdding: .month,
                                              value: month,
                                              to: self.baseDate) ?? self.baseDate
    }
    
    private func updatePrevButton() {
        prevMonthButton.isEnabled = Calendar.current.compare(Date(), to: baseDate, toGranularity: .month) == .orderedAscending
        prevMonthButton.alpha = (prevMonthButton.isEnabled) ? 1.0 : 0.5
    }
    
    private func updateNextButton() {
        guard let latestDateAllowed = Calendar.current.date(byAdding: .month, value: 12, to: Date()) else {
            assertionFailure("Failed to unwrap latestDateAllowed")
            return
        }
        
        switch Calendar.current.compare(baseDate, to: latestDateAllowed, toGranularity: .month) {
        case .orderedAscending:
            nextMonthButton.isEnabled = true
        case .orderedSame:
            nextMonthButton.isEnabled = false
        default:
            assertionFailure("baseDate should not be > latestDate")
        }
        nextMonthButton.alpha = (nextMonthButton.isEnabled) ? 1.0 : 0.5
    }
}

