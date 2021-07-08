//
//  Source.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 7/6/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class Source: NSObject
{
    let NUM_DUP_DATA_SETS: Int = 1000
    let isInfiniteCollectionView: Bool
    let viewModels: [ViewModelProtocol]
    
    init(viewModels: [ViewModelProtocol], isInfiniteCollectionView: Bool = false) {
        self.isInfiniteCollectionView = isInfiniteCollectionView
        self.viewModels = viewModels
    }
}

extension Source: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (isInfiniteCollectionView ? NUM_DUP_DATA_SETS : 1) * viewModels.count
    }
    
    #warning("I might have a problem with cell reuse in collection views that show many cells")
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item % viewModels.count
        let viewModel = viewModels[item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cell.cellId, for: indexPath)
        viewModel.config(cell: cell, indexPath: IndexPath(item: item, section: indexPath.section))
        return cell
    }
}

extension Source: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = indexPath.item % viewModels.count
        let viewModel = viewModels[item]
        viewModel.callback()
    }
}

extension Source: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = indexPath.item % viewModels.count
        let viewModel = viewModels[item]
        return viewModel.size(collectionViewBounds: collectionView.bounds)
    }
}
