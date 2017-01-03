//
//  ChartTypeSegmentedControl.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit

class ChartTypeSegmentedControl: UISegmentedControl {

    override func awakeFromNib() {
        let chartTypeSegmentedControlHeight = self.frame.size.height
        let helveticsNeue13 = FontHelper.getDefaultFont(size: 13.0, bold: true)
        let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.00)
        let imageWithColorOrigin = CGPoint(x: 0, y: chartTypeSegmentedControlHeight - 1)
        let imageWithColorSize = CGSize(width: 1, height: chartTypeSegmentedControlHeight)
        
        self.setTitleTextAttributes([NSFontAttributeName: helveticsNeue13,NSForegroundColorAttributeName:UIColor.lightGray], for:UIControlState.normal)
        self.setTitleTextAttributes([NSFontAttributeName:helveticsNeue13,NSForegroundColorAttributeName: selectedBlueColor], for:UIControlState.selected)
        self.setDividerImage(UIImage.imageWithColor(color: UIColor.clear, origin: imageWithColorOrigin, size: imageWithColorSize), forLeftSegmentState: UIControlState.normal, rightSegmentState: UIControlState.normal, barMetrics: UIBarMetrics.default)
        self.setBackgroundImage(UIImage.imageWithColor(color: UIColor.lightGray, origin: imageWithColorOrigin, size: imageWithColorSize), for:UIControlState.normal, barMetrics:UIBarMetrics.default)
        self.setBackgroundImage(UIImage.imageWithColor(color: selectedBlueColor, origin: imageWithColorOrigin, size: imageWithColorSize), for:UIControlState.selected, barMetrics:UIBarMetrics.default);
    }
    
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: .white), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: .white), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
