//
//  fetchDataClass.swift
//  currencyRate
//
//  Created by Андрей Мотырев on 15.10.2022.
// "82.6773"}}

import Foundation

class FetchData {
    
    func fetchValues(url: String)  -> String    {
        
        var valueforReturn = ""
        guard let url = URL(string: url) else {return ""}
            guard let data = (try? Data(contentsOf: url)) else { return "error"}
            let stringData = String(data: data, encoding: .ascii)
            var splitData = stringData?.components(separatedBy: ":").last?.components(separatedBy: ":").last
            splitData = String(splitData!.dropFirst())
            splitData = String(splitData!.dropLast(3))
            print (splitData!)
            valueforReturn = splitData!
        return valueforReturn
    }
}
