//
//  CollectionViewCell.swift
//  currencyRate
//
//  Created by Андрей Мотырев on 15.10.2022.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var changeValueLabel: UILabel!
    @IBOutlet weak var changePercentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var currancyLabel: UILabel!
    var id = ""
    var nominal = 1

    func changeColor(currency: Valute)  {
        var color = UIColor(white: 0.7, alpha: 0.2)
        if (currency.Value > currency.Previous) {
            color = UIColor(red: 0, green: 1, blue: 0, alpha: 0.2)
        } else if (currency.Value < currency.Previous)  {
            color = UIColor(red: 1, green: 0, blue: 0, alpha: 0.2)
        }
        print("Value = \(currency.Value)")
        print("Previous = \(currency.Previous)")
        changeValueLabel.backgroundColor = color
        changePercentLabel.backgroundColor = color
    }
    
    func percentValue(currency: Valute) -> Double    {
        let onePercent = 100 / currency.Value
        let result = onePercent * (currency.Value - currency.Previous)
        return result
    }
    
}
