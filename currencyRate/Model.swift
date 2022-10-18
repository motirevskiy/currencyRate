//
//  Model.swift
//  currencyRate
//
//  Created by Андрей Мотырев on 15.10.2022.
//

import UIKit

struct Welcome: Decodable {
    let Date, PreviousDate: String
    let PreviousURL: String
    let Timestamp: String
    let Valute: [String: Valute]
}

struct Valute: Decodable {
    let ID, NumCode, CharCode: String
    let Nominal: Int
    let Name: String
    let Value, Previous: Double

}

class Model {
    
    let url = URL(string: "https://www.cbr-xml-daily.ru/daily_json.js")
    let session = URLSession(configuration: .default)
    var value: Welcome?
    var currencyArray = ["USD", "EUR", "GBP", "UAH"]

    func dataFetch()   {
        let task = session.dataTask(with: self.url!){(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let values = try JSONDecoder().decode(Welcome.self, from: data)
                self.value = values
            }  catch   {
                print(error)
            }
            
        }
        task.resume()
    }
}
