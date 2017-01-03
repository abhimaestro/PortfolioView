//
//  Extensions.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/25/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation

func autoExecuteAfter(seconds waitSeconds: Int = 2, action: @escaping (() -> ())) {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(100), execute: action)
}

public extension UIImage {
    static func imageWithColor(color: UIColor, origin: CGPoint = CGPoint.zero, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        
        let rect = CGRect(origin: .init(x: 0, y: size.height - 1), size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

extension UITextField {
    func underlined(color: UIColor){
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func addIcon(imageName: String) {
        self.leftViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named: imageName)
        
        let containerView = UIView(frame: CGRect(0, 0, 30, 20))
        containerView.addSubview(imageView)

        self.leftView = containerView
    }
}

public extension UIView {
    func getYPositionToCenterContentInContainer(height: CGFloat, offset: CGFloat, noOfItems: Int, noOfCols: Int) -> CGFloat {
        let noOfRows = CGFloat(noOfItems/noOfCols)
        let y = CGFloat((self.frame.height - noOfRows*height - (noOfRows - 1)*offset) / 2.0)
        return y
    }
}
