//
//  CitiesList.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit

class CitiesList: NSObject {

    let baseRequest = BaseRequest()
   static let shared = CitiesList()
    
    
    func Getcities(with parameters : [String : Any], onSuccess : @escaping(CityModel)->(), onFailure : @escaping(String)->()) {
        
        baseRequest.postJsonData(with: .Getcities, parameters: parameters, onSuccess: { (responseData) in
            do {
              let listData = try JSONDecoder().decode(CityModel.self, from: responseData)
              onSuccess(listData)
            }
            catch{
                print(error.localizedDescription)
              onFailure(error.localizedDescription)
            }
        }) { (error) in
            
        }

    }
    func getWeatherDetails(with cityName : String, onSuccess : @escaping(WeatherModel)->(), onFailure : @escaping(String)->()) {
        
        baseRequest.getJsonData(with: .GetWeather, cityName: cityName, onSuccess: { (responsedata) in
            do {
                         let listData = try JSONDecoder().decode(WeatherModel.self, from: responsedata)
                         onSuccess(listData)
                       }
                       catch{
                           print("error : \(error)")
                         onFailure(error.localizedDescription)
                       }
        }) { (error) in

        }
       
    }
}
