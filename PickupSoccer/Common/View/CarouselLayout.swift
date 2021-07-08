//
//  CarouselLayout.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 4/27/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

struct CarouselLayoutConstants
{
    static let minCellHeight: CGFloat = SCREEN_HEIGHT * 0.20
    static let maxCellHeight: CGFloat = SCREEN_HEIGHT * 0.25
    static let minCellWidth: CGFloat = SCREEN_WIDTH * 0.60
    static let activeDistance: CGFloat = SCREEN_WIDTH * 0.60
    static let horizontalSpaceBetweenCells: CGFloat = 20.0
}

class CarouselLayout: UICollectionViewFlowLayout
{
    override init() {
        super.init()
        scrollDirection = .horizontal
        let maxZoom: CGFloat = CarouselLayoutConstants.maxCellHeight / CarouselLayoutConstants.minCellHeight
        let deltaWidth = CarouselLayoutConstants.minCellWidth * (maxZoom - 1.0)
        minimumLineSpacing = CarouselLayoutConstants.horizontalSpaceBetweenCells + (deltaWidth / 2.0)
        itemSize = CGSize(width: CarouselLayoutConstants.minCellWidth, height: CarouselLayoutConstants.minCellHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let rectAttributes = super.layoutAttributesForElements(in: rect)?.compactMap({ $0.copy() as? UICollectionViewLayoutAttributes }) else { return nil}
        guard let collectionView = collectionView else { return nil }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.frame.midX
            if distance.magnitude < CarouselLayoutConstants.activeDistance {
                let normalizedDistance = distance.magnitude / CarouselLayoutConstants.activeDistance
                let zoom: CGFloat = ((CarouselLayoutConstants.maxCellHeight - CarouselLayoutConstants.minCellHeight) * (1.0 - normalizedDistance) + CarouselLayoutConstants.minCellHeight) / CarouselLayoutConstants.minCellHeight
                attributes.transform = CGAffineTransform(scaleX: zoom, y: zoom)
            }
            print("visible frame = \(attributes.frame)")
        }
        print()

        return rectAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        let targetRect = CGRect(x: proposedContentOffset.x,
                                y: 0,
                                width: collectionView.frame.width,
                                height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemsMinX = layoutAttributes.frame.midX
            if (itemsMinX - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemsMinX - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
