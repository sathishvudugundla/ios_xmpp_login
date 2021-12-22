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
