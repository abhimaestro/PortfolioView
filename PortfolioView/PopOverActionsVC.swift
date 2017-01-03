//
//  PopOverActionsVC.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/27/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class PopOverMenuVC: UIViewController {
    
    typealias menuItemType = (text: String, action: (() -> Void)?)
    
    var menuItems : [menuItemType] = []
    
    init(){
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.popover
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        formatView()
        
        var y : CGFloat = 15.0
        for (index, menuItem) in menuItems.enumerated() {
            let button = getButton(menuItem: menuItem, index)
            button.frame = CGRect(15, y, 140, 30)
            y += 30
            
            self.view.addSubview(button)
        }
    }
    
    private func formatView(){
        self.view.backgroundColor = Color.darkBlue
        self.popoverPresentationController!.backgroundColor = self.view.backgroundColor
        self.preferredContentSize = CGSize(width: 150, height: (30*menuItems.count + 15 + 15)) //height = (heightOfButton * #ofButtons) + topPadding + bottomPadding
    }
    
    private func getButton(menuItem: menuItemType, _ tag: Int) -> UIButton {
        let button   = UIButton(type: .system) as UIButton
        button.tag = tag
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle(menuItem.text, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = FontHelper.getDefaultFont(size: 12.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.addTarget(self, action: #selector(self.menuItemClicked), for: UIControlEvents.touchUpInside)
        return button
    }
    
    //NOTE: should not be private as it is involved by the framework at runtime
    func menuItemClicked(sender: UIButton!){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        menuItems[sender.tag].action?()
    }
}
