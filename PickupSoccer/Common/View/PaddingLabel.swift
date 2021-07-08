//
//  PaddingLabel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    let insets: UIEdgeInsets
    
    required init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
