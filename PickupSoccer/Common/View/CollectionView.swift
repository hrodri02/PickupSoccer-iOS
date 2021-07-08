//
//  CollectionView.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 7/7/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class CollectionView: UICollectionView
{
    var source: Source? {
        didSet {
            dataSource = source
            delegate = source
        }
    }
    
    init(layout: UICollectionViewLayout) {
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
