//
//  ViewController.swift
//  currencyRate
//
//  Created by Андрей Мотырев on 17.10.2022.
//

import UIKit
import Charts

struct Record   {
    let date: String
    let value: String
}

class ViewController: UIViewController, ChartViewDelegate {
    
    var currentCurrancy = ""
    
    @IBOutlet weak var currancyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var lineChart = LineChartView()
    
    var nominal = 1
    var id = ""
    var currentDate = ""
    var urlString = ""
    let constLink = "https://www.cbr.ru/scripts/XML_dynamic.asp?date_req1="
    let secondPartConstLink = "&date_req2="
    let thirdPartConstLink = "&VAL_NM_RQ="
    
    var records: [Record] = []
    var elementName = ""
    var date = ""
    var value = ""
    var dataSetFactory = ChartDatasetFactory()
    
    
    
//TODO: Graphs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        currentDate = dateFormatter.string(from: NSDate() as Date).description
        print(currentDate)
        self.makeLink(Period: "Mounth")
        self.fetchData()
        lineChart.delegate = self
        currancyLabel.text = currentCurrancy
    }
    
    @IBAction func changedValuePeriod(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex  {
        case 0:
            self.makeLink(Period: "Year")
        case 1:
            self.makeLink(Period: "Mounth")
        case 2:
            self.makeLink(Period: "Week")
        default:
            return
        }
        self.fetchData()
    }
    func makeGraphs()   {
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.self.width,
                                            height: self.view.frame.self.width)
        lineChart.center = CGPoint(x: self.view.frame.self.width/2, y: self.view.frame.self.width/1.3)
        view.addSubview(lineChart)
        var lineChartEntries = [BarChartDataEntry]()
        var counter: Double = 0
        for elem in self.records {
            print(elem.value)
            var stringToDouble = ""
            for el in elem.value    {
                if el == ","    {
                    stringToDouble += "."
                }
                else    {
                    stringToDouble += "\(el)"
                }
            }
            var double = Double(stringToDouble)!
            double = double / Double(nominal)
            lineChartEntries.append(BarChartDataEntry(x: counter, y: double ,data: elem.date))
            counter += 1
        }
        let dataSet = dataSetFactory.makeChartDataset(colorAsset: DataColor.third, entries: lineChartEntries)
        let data = LineChartData(dataSet: dataSet)
        lineChart.data = data
        
        //настройка отоброжения сетки
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.drawGridBackgroundEnabled = false
        // настройка подписей к осям
        lineChart.xAxis.drawLabelsEnabled = false
        lineChart.leftAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        // настройка легенды
        lineChart.legend.enabled = false
        // артефакты
        lineChart.xAxis.enabled = false
        lineChart.leftAxis.enabled = false
        lineChart.rightAxis.enabled = false
        lineChart.drawBordersEnabled = true
        lineChart.minOffset = 6
        // оформление, связанное с выбором значения на графике
        dataSet.drawHorizontalHighlightIndicatorEnabled = false // оставляем только вертикальную линию
        dataSet.highlightLineWidth = 2 // толщина вертикальной линии
        dataSet.highlightColor = .blue // цвет вертикальной линии
        // баблик
        let circleMarker = CircleMarker()
        lineChart.drawMarkers = true
        circleMarker.chartView = lineChart
        lineChart.marker = circleMarker
        //zoom
        lineChart.scaleXEnabled = true
        lineChart.scaleYEnabled = false
        //animation
        lineChart.animate(yAxisDuration: 2)
        
        dataSet.lineWidth = 3
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        self.dateLabel.text = entry.data as? String
        self.valueLabel.text = String(format: "%.3f", entry.y)
        print(entry)
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        self.dateLabel.isHidden = true
        self.valueLabel.isHidden = true
    }
    
    func fetchData()    {
        self.records.removeAll()
        let session = URLSession(configuration: .default)
        guard let url = URL(string: urlString) else { return }
        let task = session.dataTask(with: url){(data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else { return }
                //print(String(data: data, encoding: .utf8))
                let parser = XMLParser(data: data)
                    parser.delegate = self
                    if parser.parse()   {
                        self.makeGraphs()
                    }
            }
        }
        task.resume()
    }
    
    func makeLink(Period p: String) {
        var prevDate = ""
        var prevDateArray = self.currentDate.components(separatedBy: "/")
        if p == "Mounth"    {
            let prevMounth = Int(prevDateArray[1])
            prevDateArray[1] = prevMounth! > 1 ? (prevMounth! - 1).description : 12.description
            prevDateArray[1] = Int(prevDateArray[1])! < 10 ? "0" + prevDateArray[1] : prevDateArray[1]
            prevDate = prevDateArray[0] + "/" + String(prevDateArray[1]) + "/" + prevDateArray[2]
        }
        else if p == "Year" {
            let prevYear = Int(prevDateArray[2])! - 1
            prevDateArray[2] = prevYear.description
            prevDate = prevDateArray[0] + "/" + String(prevDateArray[1]) + "/" + prevDateArray[2]
        } else {
            let prevWeekDay = Int(prevDateArray[0])! > 7 ? Int(prevDateArray[0])! - 7 : 31 - Int(prevDateArray[0])!
            prevDateArray[0] = prevWeekDay.description
            prevDateArray[0] = Int(prevDateArray[0])! < 10 ? "0" + prevDateArray[0] : prevDateArray[0]
            prevDate = prevDateArray[0] + "/" + String(prevDateArray[1]) + "/" + prevDateArray[2]
        }
        urlString = self.constLink + prevDate +
        self.secondPartConstLink +
        self.currentDate +
        self.thirdPartConstLink + self.id
        print(urlString)
    }

}
extension ViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Record"  {
            if let date = attributeDict["Date"] {
                self.date = date
            }
            self.value = ""
        }
        self.elementName = elementName
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Record"  {
            let record = Record(date: date, value: value)
            records.append(record)
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !string.isEmpty    {
            if self.elementName == "Value"  {
                self.value += string
            }
        }
    }
}


//// Фабрика подготовки датасета для графика
struct ChartDatasetFactory {
    func makeChartDataset(
        colorAsset: DataColor,
        entries: [ChartDataEntry]
    ) -> LineChartDataSet {
        var dataSet = LineChartDataSet(entries: entries, label: "")
        // общие настройки графика
        dataSet.setColor(colorAsset.color)
        dataSet.lineWidth = 3
        dataSet.mode = .cubicBezier // сглаживание
        dataSet.drawValuesEnabled = false // убираем значения на графике
        dataSet.drawCirclesEnabled = false // убираем точки на графике
        dataSet.drawFilledEnabled = true // нужно для градиента
        addGradient(to: &dataSet, colorAsset: colorAsset)
        return dataSet
    }
}
private extension ChartDatasetFactory {
    func addGradient(
        to dataSet: inout LineChartDataSet,
        colorAsset: DataColor
    ) {
        let mainColor = colorAsset.color.withAlphaComponent(0.8)
        let secondaryColor = colorAsset.color.withAlphaComponent(0)
        let colors = [
            mainColor.cgColor,
            secondaryColor.cgColor,
            secondaryColor.cgColor
        ] as CFArray
        let locations: [CGFloat] = [0, 1, 1]
        if let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: locations
        ) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
        }
    }
}

enum DataColor {
    case first
    case second
    case third
    var color: UIColor {
        switch self {
        case .first:
            return UIColor(
                red: 56/255,
                green: 58/255,
                blue: 209/255,
                alpha: 1
            )
        case .second:
            return UIColor(
                red: 235/255,
                green: 113/255,
                blue: 52/255,
                alpha: 1
            )
        case .third:
            return UIColor(
                red: 52/255,
                green: 235/255,
                blue: 143/255,
                alpha: 1
            )
        }
    }
}

/// Круговой маркер для отображения выбранной точки на графике
final class CircleMarker: MarkerView {
    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(2)
        let radius: CGFloat = 8
        let rectangle = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        context.addEllipse(in: rectangle)
        context.drawPath(using: .fillStroke)
    }
}
