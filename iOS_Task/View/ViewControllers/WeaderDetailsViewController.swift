//
//  WeaderDetailsViewController.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit

class WeaderDetailsViewController: UIViewController {
    var weatherDetails:List?
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var cloudCoverLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    @IBOutlet var rainLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateData()
    }
    
    @IBAction func BackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func updateData()
    {
        self.cityLabel.text = weatherDetails?.name
        
        self.weatherLabel.text = weatherDetails!.weather?[0].weatherDescription
        
        self.temperatureLabel.text = "\(weatherDetails!.main?.temp ?? 0)°"
        
        self.cloudCoverLabel.text = "\(weatherDetails!.clouds!.today )"
        
        self.windLabel.text = "\(weatherDetails!.wind!.speed )"
        
        self.rainLabel.text = "\(weatherDetails!.main?.pressure ?? 0)"
               
        self.humidityLabel.text = "\(weatherDetails!.main?.humidity ?? 0)%"
    }

}
extension WeaderDetailsViewController
{
static func getRootController() -> WeaderDetailsViewController {
    let st  = UIStoryboard(name: "Main", bundle: nil)
    return st.instantiateViewController(withIdentifier: "WeaderDetailsViewController") as! WeaderDetailsViewController
}
    
}
