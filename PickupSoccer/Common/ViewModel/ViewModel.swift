//
//  ViewModel.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 7/6/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

protocol ViewModelProtocol
{
    var cell: UICollectionViewCell.Type { get }
    func config(cell: UICollectionViewCell, indexPath: IndexPath)
    func callback()
    func size(collectionViewBounds: CGRect) -> CGSize
}

class ViewModel<View, Model>: ViewModelProtocol where View: UICollectionViewCell, Model: Any
{
    public var cell: UICollectionViewCell.Type { return View.self }
    public weak var view: View?
    public let model: Model
    private var selectionHandler: ((ViewModel<View, Model>) -> Void)?
    
    init(model: Model) {
        self.model = model
    }
    
    func config(cell: UICollectionViewCell, indexPath: IndexPath) {
        view = cell as? View
    }
    
    func callback() {
        self.selectionHandler?(self)
    }
    
    func size(collectionViewBounds: CGRect) -> CGSize {
        return CGSize.zero
    }
    
    func onSelect(_ completionHandler: @escaping (ViewModel<View, Model>) -> Void) {
        self.selectionHandler = completionHandler
    }
}
