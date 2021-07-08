//
//  DayViewModel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 7/7/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class DayViewModel: ViewModel<CalendarDateViewCVCell, Day>
{
    var numOfWeeksInMonth: Int
    
    init(day: Day, numOfWeeksInMonth: Int) {
        self.numOfWeeksInMonth = numOfWeeksInMonth
        super.init(model: day)
    }
    
    private static let accessibilityDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return dateFormatter
    }()
    
    override func config(cell: UICollectionViewCell, indexPath: IndexPath) {
        super.config(cell: cell, indexPath: indexPath)
        view?.numberLabel.text = model.number
        view?.accessibilityLabel = DayViewModel.accessibilityDateFormatter.string(from: model.date)
        view?.updateSelectionStatus(day: model)
    }
    
    override func size(collectionViewBounds: CGRect) -> CGSize {
        let width = Int(collectionViewBounds.width / 7)
        let height = Int(collectionViewBounds.height) / numOfWeeksInMonth
        return CGSize(width: width, height: height)
    }
}
