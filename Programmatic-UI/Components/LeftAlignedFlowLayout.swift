//
//  LeftAlignedFlowLayout.swift
//  Programmatic-UI
//
//  Created by Khanh Anh Kiet on 2026-03-11.
//


import UIKit

class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        
        var maxY: CGFloat = -1.0
        
        attributes?.forEach { layoutAttribute in
            guard layoutAttribute.representedElementCategory == .cell else { return }
            
            //Y > SCREEN_HEIGHT -> NEW LINE
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            // X need to be in left
            layoutAttribute.frame.origin.x = leftMargin
            
            // Update newLeftMargin = width + spacing + old margin
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            //update screen height
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
