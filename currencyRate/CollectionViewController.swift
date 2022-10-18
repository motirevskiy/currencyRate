//
//  CollectionViewController.swift
//  currencyRate
//
//  Created by Андрей Мотырев on 15.10.2022.
//

import UIKit

class CollectionViewController: UICollectionViewController {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var model = Model()
    var timer = Timer()
    let intervalForTimer: Double = 60
    var tick = 0
    
    @IBOutlet weak var navigatorItem: UINavigationItem!
    
    override func viewDidLoad() {
        self.activity.hidesWhenStopped = true
        self.activity.startAnimating()
        self.activity.layer.zPosition = 1
        self.fetch()
        sleep(1)
        self.collectionView.reloadData()
    }
    
    func makeTimer(timeInterval ti: Double)    {
        self.timer.invalidate()
        self.tick = 0
        self.timer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.currencyArray.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        // Configure the cell
        cell.currancyLabel.text = self.model.currencyArray[indexPath.item]
        cell.layer.cornerRadius = 5
        cell.changeValueLabel.layer.masksToBounds = true
        cell.changeValueLabel.layer.cornerRadius = 4
        cell.changePercentLabel.layer.masksToBounds = true
        cell.changePercentLabel.layer.cornerRadius = 4
        guard self.model.value != nil else { return cell }
        let currency = self.model.value!.Valute[self.model.currencyArray[indexPath.item]]!
        cell.nominal = currency.Nominal
        cell.id = currency.ID
        cell.nameLabel.text = currency.Name
        cell.valueLabel.text = (currency.Value / Double(cell.nominal)).description
        cell.changeColor(currency: currency)
        let percent = String(format: "%.2f", cell.percentValue(currency: currency)) + "%"
        let singleChanged = String(format: "%.2f", currency.Value - currency.Previous)
        cell.changePercentLabel.text = percent
        cell.changeValueLabel.text = singleChanged
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVc = segue.destination as! ViewController
        let sender = sender as! CollectionViewCell
        secondVc.id = sender.id
        secondVc.nominal = sender.nominal
        secondVc.currentCurrancy = sender.currancyLabel.text!
    }
    
    func showAlert()    {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    @objc func fetch()    {
        self.activity.startAnimating()
        self.collectionView.isScrollEnabled = false
        DispatchQueue.global().async {
                self.model.dataFetch()
            }
            DispatchQueue.main.async {
                self.collectionView.isScrollEnabled = true
                self.activity.stopAnimating()
                self.collectionView.reloadData()
            }
    }
    
    @IBAction func reload(_ sender: Any) {
        self.activity.startAnimating()
        self.makeTimer(timeInterval: intervalForTimer)
        self.fetch()
    }
    @IBAction func addCurrency(_ sender: Any) {
        let alert = UIAlertController(title: "Add Currency", message: nil, preferredStyle: .alert)
        alert.addTextField  {(textField: UITextField!) -> Void in
            textField.placeholder = "New Currency"
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { alert -> Void in
                if self.model.value?.Valute[textField.text?.uppercased() ?? ""] == nil   {
                    self.showAlert()
                    return
                }
                self.model.currencyArray.append(textField.text?.uppercased() ?? "")
                self.fetch()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension CollectionViewCell: UICollectionViewDelegateFlowLayout    {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 100, height: UIScreen.main.bounds.height)
        }
}
