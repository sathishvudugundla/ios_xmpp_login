//
//  ListOfWeatherViewController.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit
import CoreData
class ListOfWeatherViewController: UIViewController {

    private var observer: NSObjectProtocol?
    @IBOutlet var CitiesTV: UITableView!
    var cityName = ""
    let viewModel = CityViewModel()
    var Lists = [List]()
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: "Register")
        if XmppClient.shared.checketwork()
        {
             viewModel.fetchCitiesList(cityName: "india")
             prepareViewModelObserver()
        }
        else
        {
            // if network not available get data from coredata
            retrieveData()
        }
        
       
        setUpTableview()
        
        // app enter background
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [unowned self] notification in
                   // save weather data when app enter background
            self.createData()
                }
        
    }
    deinit {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    func setUpTableview() {
        self.CitiesTV.bounces              = true
        self.CitiesTV.delegate             = self
        self.CitiesTV.dataSource           = self
        self.CitiesTV.estimatedRowHeight = UITableView.automaticDimension
        self.CitiesTV.backgroundColor      = .white
        self.CitiesTV.tableFooterView = UIView()
        self.CitiesTV.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "CityTableViewCell")
    }
    
    func createData(){
        
      
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "WeatherList", in: managedContext)!
        
        for item in viewModel.cities! {
            
            let list = NSManagedObject(entity: userEntity, insertInto: managedContext)
            list.setValue(item.name, forKey: "name")
            list.setValue(item.main?.temp, forKey: "temp")
            list.setValue(item.main?.feelsLike, forKey: "feelsLike")
            list.setValue(item.main?.tempMin, forKey: "tempMin")
            list.setValue(item.main?.tempMax, forKey: "tempMax")
            list.setValue(item.main?.pressure, forKey: "pressure")
            list.setValue(item.main?.humidity, forKey: "humidity")
            list.setValue(item.main?.seaLevel, forKey: "seaLevel")
            list.setValue(item.main?.grndLevel, forKey: "grndLevel")
            list.setValue(item.wind?.speed, forKey: "speed")
            list.setValue(item.wind?.deg, forKey: "deg")
            list.setValue(item.clouds?.today, forKey: "today")
            
           
        }

        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherList")
 
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
//                print(data)
               
                let MainClassitem = MainClass(temp: data.value(forKey: "temp") as! Double, feelsLike: data.value(forKey: "feelsLike") as! Double, tempMin: data.value(forKey: "tempMin") as! Double, tempMax: data.value(forKey: "tempMax") as! Double, pressure: data.value(forKey: "pressure") as! Int, humidity: data.value(forKey: "humidity") as? Int ?? 0, seaLevel: data.value(forKey: "seaLevel") as? Int ?? 0, grndLevel: data.value(forKey: "grndLevel") as? Int ?? 0)
                let listItem = List(id: 0, name: data.value(forKey: "name") as? String, coord: nil, main: MainClassitem , visibility: 0, wind: Wind(speed: data.value(forKey: "speed") as! Double, deg: data.value(forKey: "deg") as! Int), rain: nil, clouds: Clouds(today: data.value(forKey: "today") as! Int), weather: nil)
                Lists.append(listItem)
            }
            viewModel.cities = Lists
            print(Lists.count)
            self.CitiesTV.reloadData()
            
        } catch {
            
            print("Failed")
        }
    }
}
extension ListOfWeatherViewController {
    
    static func getRootController() -> UINavigationController {
        let st  = UIStoryboard(name: "Main", bundle: nil)
        return st.instantiateViewController(withIdentifier: "ListOfWeatherViewController") as! UINavigationController
    }
    
    func prepareViewModelObserver() {
        self.viewModel.cityDidChanges = { (finished, error) in
            if !error {
                print("reload")
               self.createData()
                self.CitiesTV.reloadData()
            }
        }
    }
    
}

extension ListOfWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cities!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell: CityTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath as IndexPath) as? CityTableViewCell else {
            fatalError("AddressCell cell is not found")
        }
        
        let model = viewModel.cities![indexPath.row]
        cell.nameLbl.text = model.name
        cell.TemperatureLbl.text = "Temperature : \(model.main?.temp ?? 0)°"
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let list = viewModel.cities![indexPath.row]
        
        let vc = WeaderDetailsViewController.getRootController()
        vc.weatherDetails = list

        self.showVC(vc: vc)
    }
    func showVC(vc: UIViewController) {
        if let nv = self.navigationController {
            
            nv.pushViewController(vc, animated: true)
        }else{
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}
