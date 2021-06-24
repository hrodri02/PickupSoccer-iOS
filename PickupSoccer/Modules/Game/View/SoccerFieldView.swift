//
//  File.swift
//  PickupSoccer
//
//  Created by Heriberto Rodriguez on 6/24/21.
//  Copyright © 2021 Heriberto Rodriguez. All rights reserved.
//

import UIKit

class SoccerFieldView: UIView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func draw() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.init(white: 0.9, alpha: 1.0).cgColor
        let collectionViewWidth = bounds.width
        let collectionViewHeight = bounds.height
        
        let soccerFieldPath = UIBezierPath(rect: CGRect(x: 0, y: 0,
                                                      width: bounds.width,
                                                      height:bounds.height))
        
        let middleLinePath = UIBezierPath()
        middleLinePath.move(to: CGPoint(x: 0, y: bounds.height / 2.0))
        middleLinePath.addLine(to: CGPoint(x: bounds.width,
                                           y: bounds.height / 2.0))
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0),
                                      radius: bounds.width / 8.0,
                                      startAngle: CGFloat(0.0),
                                      endAngle: CGFloat(2.0 * .pi),
                                      clockwise: true)
        let littleCircleShape = CAShapeLayer()
        littleCircleShape.fillColor = UIColor.init(white: 0.9, alpha: 1.0).cgColor
        let littleCirclePath = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0),
                                            radius: 1.5,
                                            startAngle: CGFloat(0.0),
                                            endAngle: CGFloat(2.0 * .pi),
                                            clockwise: true)
        littleCircleShape.path = littleCirclePath.cgPath
        
        let goalielittleRectWidth = collectionViewWidth * 0.25
        let upperLittleRect = UIBezierPath(rect: CGRect(x: (collectionViewWidth - goalielittleRectWidth) / 2.0,
                                                        y: 0,
                                                        width: goalielittleRectWidth,
                                                        height: goalielittleRectWidth / 3.0))
        let goalieBigRectWidth = collectionViewWidth * 0.5
        let upperBigRect = UIBezierPath(rect: CGRect(x: (collectionViewWidth - goalieBigRectWidth) / 2.0,
                                                     y: 0,
                                                     width: goalieBigRectWidth,
                                                     height: goalieBigRectWidth / 3.0))
        let deltaY = (goalielittleRectWidth / 2.0 - 10.0) * sin(15.0 * .pi / 180.0)
        let upperArcPath = UIBezierPath(arcCenter: CGPoint(x: collectionViewWidth / 2.0, y: goalieBigRectWidth / 3.0 - deltaY),
                                        radius: goalielittleRectWidth / 2.0 - 10.0,
                                        startAngle: CGFloat(15.0 * .pi / 180.0),
                                        endAngle: CGFloat(.pi * (1.0 - 15.0 / 180.0)),
                                        clockwise: true)
        
        let lowerLittleRect = UIBezierPath(rect: CGRect(x: (collectionViewWidth - goalielittleRectWidth) / 2.0,
                                                       y: collectionViewHeight - (goalielittleRectWidth / 3.0),
                                                       width: goalielittleRectWidth,
                                                       height: goalielittleRectWidth / 3.0))
        let lowerBigRect = UIBezierPath(rect: CGRect(x: (collectionViewWidth - goalieBigRectWidth) / 2.0,
                                                     y: collectionViewHeight - (goalieBigRectWidth / 3.0),
                                                     width: goalieBigRectWidth,
                                                     height: goalieBigRectWidth / 3.0))
        let lowerArcPath = UIBezierPath(arcCenter: CGPoint(x: collectionViewWidth / 2.0, y: collectionViewHeight - goalieBigRectWidth / 3.0 + deltaY),
                                                           radius: goalielittleRectWidth / 2.0 - 10.0,
                                                           startAngle: CGFloat(.pi * (1.0 + 15.0 / 180.0)),
                                                           endAngle: CGFloat(.pi * (2.0 - 15.0 / 180.0)),
                                                           clockwise: true)
        
        soccerFieldPath.append(middleLinePath)
        soccerFieldPath.append(upperLittleRect)
        soccerFieldPath.append(upperBigRect)
        soccerFieldPath.append(upperArcPath)
        soccerFieldPath.append(lowerLittleRect)
        soccerFieldPath.append(lowerBigRect)
        soccerFieldPath.append(lowerArcPath)
        soccerFieldPath.append(circlePath)
        shapeLayer.path = soccerFieldPath.cgPath
        
        layer.addSublayer(shapeLayer)
        layer.addSublayer(littleCircleShape)
    }
}
