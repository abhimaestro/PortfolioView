//
//  DashboardViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/15/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import Foundation
import PortfolioViewShared

class DashboardViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var portfolioTotalMarketValueLabel: UILabel!
    @IBOutlet weak var topChartContainer: UIView!
    @IBOutlet weak var portraitLayoutContainer: UIView!
    @IBOutlet weak var landscapeLayoutContainer: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var bottomContainerPageControl: UIPageControl!
    @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var trailingPeriod1MButton: UIButton!
    @IBOutlet weak var trailingPeriod3MButton: UIButton!
    @IBOutlet weak var trailingPeriod1YrButton: UIButton!
    @IBOutlet weak var trailingPeriod3YrButton: UIButton!
    @IBOutlet weak var trailingPeriod5YrButton: UIButton!
    @IBOutlet weak var trailingPeriodAllButton: UIButton!

    var marketDataContainer: MarketDataView!
    var accountDataContainer: AccountDataView!
    var allocationDataContainer: AllocationView!
    var goalContainer: GoalView!
    var performanceContainer: PerformanceView!
    var valueOverTimeContainer: ValueOverTimeView!
    
    let trailingPeriodButtonSelectedFont = FontHelper.getDefaultFont(size: 13.0, bold: true)

    private enum TopContainerViewName: Int {
        case Performance = 0
        case ValueOverTime = 1
    }
    
    private enum BottomContainerViewName: Int {
        case MarketData = 0
        case Account = 1
        case Goal = 2
        case Allocation = 3
    }

    private var _currentTrailingPeriod: TrailingPeriod = .All
    private var _currentIndexType: IndexType = .Index1

    private var _topContainerViewName = TopContainerViewName.Performance {
        didSet {
            chartTypeSegmentedControl.selectedSegmentIndex = _topContainerViewName.rawValue
        }
    }
    
    private var _bottomContainerViewName = BottomContainerViewName.MarketData {
        didSet {
            bottomContainerPageControl.currentPage = _bottomContainerViewName.rawValue
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        let portfolioData = getCurrentPortfolioData()
        self.valueOverTimeContainer = ValueOverTimeView.load(portfolioData: portfolioData, container: self.topChartContainer)
        self.performanceContainer = PerformanceView.load(portfolioData: portfolioData, indexType: _currentIndexType, container: self.topChartContainer)
        
        portfolioTotalMarketValueLabel.text = portfolioData.totalPortfolioMarketValueDollar.toCurrency()
        
        addGestures()
    }
    
    func getCurrentPortfolioData() -> PortfolioData {
        return PortfolioData.load(trailingPeriod: _currentTrailingPeriod)!
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.landscapeLayoutContainer.isHidden = true
        self.portraitLayoutContainer.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            
            if UIDevice.current.orientation.isLandscape {
                
                self.landscapeLayoutContainer.isHidden = false

                for i in 0..<self.landscapeLayoutContainer.subviews.count {
                    self.landscapeLayoutContainer.subviews[i].removeFromSuperview()
                }
               
                if (self._topContainerViewName == .Performance) {
                    let _ = self.performanceContainer.getPerformanceChart(inView: self.landscapeLayoutContainer, portfolioData: self.getCurrentPortfolioData(), indexType: self._currentIndexType)
                }
                else {
                    let _ = self.valueOverTimeContainer.getValueOverTimeChart(inView: self.landscapeLayoutContainer, portfolioData: self.getCurrentPortfolioData())
                }
            }
            else {
                self.portraitLayoutContainer.isHidden = false
                self.navigationController?.isNavigationBarHidden = false
                
                for i in 0..<self.landscapeLayoutContainer.subviews.count {
                    self.landscapeLayoutContainer.subviews[i].removeFromSuperview()
                }
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.marketDataContainer = MarketDataView.load(marketData: PortfolioData.getMarketData(), container: self.bottomContainer)
        self.accountDataContainer = AccountDataView.load(accountData: PortfolioData.getAccounts(), container: self.bottomContainer)
        self.accountDataContainer.isHidden = true
        self.allocationDataContainer = AllocationView.load(allocationData: PortfolioData.getAllocations(), container: self.bottomContainer)
        self.allocationDataContainer.isHidden = true
        self.goalContainer = GoalView.load(goalInfo: PortfolioData.getGoalInfo(), container: self.bottomContainer)
        self.goalContainer.isHidden = true
    }

    private func openPopoverMenu() {
        let pomVC = PopOverMenuVC()
        
        pomVC.popoverPresentationController!.sourceView = self.performanceContainer.indexNameLabel
        pomVC.popoverPresentationController!.sourceRect = CGRect(x: 0, y: 10, width: 10, height: 10)
        pomVC.popoverPresentationController!.delegate = self
        
        pomVC.menuItems.append((text: PortfolioData.portfolioData_All!.index1Name, action: {
            [unowned self] in
            self.performanceContainer.indexNameLabel.text = PortfolioData.portfolioData_All!.index1Name
            self._currentIndexType = .Index1
            self.initializePerformanceChart()
        }))

        pomVC.menuItems.append((text: PortfolioData.portfolioData_All!.index2Name, action: {
            [unowned self] in
            self.performanceContainer.indexNameLabel.text = PortfolioData.portfolioData_All!.index2Name
            self._currentIndexType = .Index2
            self.initializePerformanceChart()
        }))
        
        pomVC.menuItems.append((text: PortfolioData.portfolioData_All!.index3Name, action: {
            [unowned self] in
            self.performanceContainer.indexNameLabel.text = PortfolioData.portfolioData_All!.index3Name
            self._currentIndexType = .Index3
            self.initializePerformanceChart()
        }))
       
        self.present(pomVC, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    private func initializePerformanceChart() {
        self.performanceContainer.initializePerformanceChart(portfolioData: self.getCurrentPortfolioData(), indexType: self._currentIndexType)
    }
    
    private func initializeValueOverTimeChart() {
        self.valueOverTimeContainer.initializeValueOverTimeChart(portfolioData: self.getCurrentPortfolioData())
    }
    
   private func addGestures(){
        let bottomContainerSwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        bottomContainerSwipeRightGesture.direction = .right
        bottomContainer.addGestureRecognizer(bottomContainerSwipeRightGesture)

        let  bottomContainerSwipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        bottomContainerSwipeLeftGesture.direction = .left
        bottomContainer.addGestureRecognizer(bottomContainerSwipeLeftGesture)

        let topContainerSwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.topContainerSwipe(swipeGesture:)))
        topContainerSwipeRightGesture.direction = .right
        topContainer.addGestureRecognizer(topContainerSwipeRightGesture)
        
        let  topContainerSwipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.topContainerSwipe(swipeGesture:)))
        topContainerSwipeLeftGesture.direction = .left
        topContainer.addGestureRecognizer(topContainerSwipeLeftGesture)

        self.performanceContainer.indexNameLabel.isUserInteractionEnabled = true
        let  indexNameTouchedGesture = UITapGestureRecognizer(target: self, action: #selector(self.indexNameTap(tapGesture:)))
        self.performanceContainer.indexNameLabel.addGestureRecognizer(indexNameTouchedGesture)

    }
    
    func resetTrailingPeriodButtonsStyle() {
        
        let helveticaNeue12 = FontHelper.getDefaultFont(size: 12.0)
        
        let color = UIColor.darkGray

        trailingPeriod1MButton.titleLabel?.font = helveticaNeue12
        trailingPeriod1MButton.setTitleColor(color, for: .normal)
        trailingPeriod3MButton.titleLabel?.font = helveticaNeue12
        trailingPeriod3MButton.setTitleColor(color, for: .normal)
        trailingPeriod1YrButton.titleLabel?.font = helveticaNeue12
        trailingPeriod1YrButton.setTitleColor(color, for: .normal)
        trailingPeriod3YrButton.titleLabel?.font = helveticaNeue12
        trailingPeriod3YrButton.setTitleColor(color, for: .normal)
        trailingPeriod5YrButton.titleLabel?.font = helveticaNeue12
        trailingPeriod5YrButton.setTitleColor(color, for: .normal)
        trailingPeriodAllButton.titleLabel?.font = helveticaNeue12
        trailingPeriodAllButton.setTitleColor(color, for: .normal)
    }
    
    @IBAction func trailingPeriodChangedTo1M(_ sender: UIButton) {
        
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(Color.darkBlue, for: .normal)
        _currentTrailingPeriod = .M1
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedTo3M(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(Color.darkBlue, for: .normal)
        _currentTrailingPeriod = .M3
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedTo1Yr(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(Color.darkBlue, for: .normal)
        _currentTrailingPeriod = .Y1
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedTo3Yr(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(Color.darkBlue, for: .normal)
        _currentTrailingPeriod = .Y3
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }

    @IBAction func trailingPeriodChangedTo5Yr(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(Color.darkBlue, for: .normal)
        _currentTrailingPeriod = .Y5
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedToAll(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = FontHelper.getDefaultFont(size: 12.0, bold: true)
        sender.setTitleColor(Color.darkBlue, for: .normal)
        _currentTrailingPeriod = .All
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func chartTypeValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            changeTopPage(direction: .right)
        }
        else {
            changeTopPage(direction: .left)
        }
    }
    
    private func changeTopPage(direction: UISwipeGestureRecognizerDirection) {
        
        
        switch direction {
        case UISwipeGestureRecognizerDirection.left:

            switch _topContainerViewName {
            case .Performance:
                toggleBetweenViews(viewsToShow: [valueOverTimeContainer], viewsToHide: [performanceContainer], toLeft: true)
                _topContainerViewName = .ValueOverTime
            case .ValueOverTime:
                break
            }
            
        case UISwipeGestureRecognizerDirection.right:
            
            switch _topContainerViewName {
            case .Performance:
                break
            case .ValueOverTime:
                toggleBetweenViews(viewsToShow: [performanceContainer], viewsToHide: [valueOverTimeContainer], toLeft: false)
                _topContainerViewName = .Performance
                break
            }
        default:
            break
        }
    }

    func indexNameTap(tapGesture: UITapGestureRecognizer) {
        openPopoverMenu()
    }

    func topContainerSwipe(swipeGesture: UISwipeGestureRecognizer) {
        changeTopPage(direction: swipeGesture.direction)
    }
    
    func bottomContainerSwipe(swipeGesture: UISwipeGestureRecognizer) {
        changeBottomPage(direction: swipeGesture.direction)
    }
    
    @IBAction func bottomContainerPageChange(_ sender: AnyObject) {
        if sender.currentPage > _bottomContainerViewName.rawValue {
            changeBottomPage(direction: .left)
        }
        else if sender.currentPage < _bottomContainerViewName.rawValue {
            changeBottomPage(direction: .right)
        }
    }
    
    private func changeBottomPage(direction: UISwipeGestureRecognizerDirection){
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            switch _bottomContainerViewName {
            case .MarketData:
                toggleBetweenViews(viewsToShow: [accountDataContainer], viewsToHide: [marketDataContainer], toLeft: true)
                _bottomContainerViewName = .Account
            case .Account:
                toggleBetweenViews(viewsToShow: [goalContainer], viewsToHide: [accountDataContainer], toLeft: true)
                _bottomContainerViewName = .Goal
            case .Goal:
                toggleBetweenViews(viewsToShow: [allocationDataContainer], viewsToHide: [goalContainer], toLeft: true)
                _bottomContainerViewName = .Allocation
            case .Allocation:
                break
            }
        case UISwipeGestureRecognizerDirection.right:
            switch _bottomContainerViewName {
            case .MarketData:
               break
            case .Account:
                toggleBetweenViews(viewsToShow: [marketDataContainer], viewsToHide: [accountDataContainer], toLeft: false)
                _bottomContainerViewName = .MarketData
            case .Goal:
                toggleBetweenViews(viewsToShow: [accountDataContainer], viewsToHide: [goalContainer], toLeft: false)
                _bottomContainerViewName = .Account
            case .Allocation:
                toggleBetweenViews(viewsToShow: [goalContainer], viewsToHide: [allocationDataContainer], toLeft: false)
                _bottomContainerViewName = .Goal
            }
        default:
            break
        }
    }
}
