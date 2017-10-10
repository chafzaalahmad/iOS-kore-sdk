//
//  PiechartView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 08/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import Charts

class PiechartBubbleView: BubbleView {
    var pcView: PieChartView!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor =  UIColor.clear
        }
    }
    
    override func initialize() {
        super.initialize()
        self.needDateLabel = false
        
        self.pcView = PieChartView()
        self.pcView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.pcView)
        
        let views: [String: UIView] = ["pcView": pcView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pcView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pcView]|", options: [], metrics: nil, views: views))
        
        let l: Legend = self.pcView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = true
        l.xEntrySpace = 7.0
        l.yEntrySpace = 0.0
        l.yOffset = -4.0
        l.formSize = 14.0
        l.textColor = .white
        l.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
        
        let description: Description = Description()
        description.text = nil
        self.pcView.chartDescription = description
        self.pcView.drawHoleEnabled = false
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
                let elementsCount: Int = elements.count
                var values: Array<PieChartDataEntry> = Array<PieChartDataEntry>()
                var currency: String? = "$"
                for i in 0..<elementsCount {
                    let dictionary = elements[i]
                    let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                    let value: NSNumber = dictionary["value"] != nil ? dictionary["value"] as! NSNumber : 0
                    if dictionary["currency"] != nil {
                        currency = dictionary["currency"] as? String
                    }
                    let pieChartDataEntry = PieChartDataEntry(value: value.doubleValue, label: title, data: dictionary as AnyObject)
                    values.append(pieChartDataEntry)
                }
                let pieChartDataSet = PieChartDataSet(values: values, label: "")
                
                var colors: Array<UIColor> = Array<UIColor>()
                colors.append(Common.UIColorRGB(0x41C5D3))
                colors.append(Common.UIColorRGB(0xC4AFF0))
                colors.append(Common.UIColorRGB(0x64D7D6))
                colors.append(Common.UIColorRGB(0x2ecc71))
                colors.append(Common.UIColorRGB(0x1abc9c))
                colors.append(Common.UIColorRGB(0x1abc9c))
                colors.append(contentsOf: ChartColorTemplates.joyful())
                colors.append(contentsOf: ChartColorTemplates.colorful())
                colors.append(contentsOf: ChartColorTemplates.liberty())
                colors.append(contentsOf: ChartColorTemplates.material())
                colors.append(contentsOf: ChartColorTemplates.pastel())
                colors.append(contentsOf: ChartColorTemplates.vordiplom())

                pieChartDataSet.colors = colors
                
                let pieChartData = PieChartData(dataSet: pieChartDataSet)
                
                let pFormatter: NumberFormatter = NumberFormatter()
                pFormatter.numberStyle = .currency
                pFormatter.maximumFractionDigits = 2
                pFormatter.multiplier = 1.0
                pFormatter.currencySymbol = currency
                
                pieChartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
                pieChartData.setValueFont(UIFont(name: "HelveticaNeue-Medium", size: 14.0))
                pieChartData.setValueTextColor(UIColor.black)
                
                self.pcView.data = pieChartData
                self.pcView.highlightValues(nil)
                self.pcView.animate(yAxisDuration: 1.4, easingOption: ChartEasingOption.easeInOutBack)
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: 320)
    }
    
    override func prepareForReuse() {
//        self.carouselView.prepareForReuse()
    }
}
