//
//  CityViewModel.swift
//  iOS_Task
//
//  Created by sathish on 21/12/21.
//

import Foundation
protocol CityViewModelDelegate {

    var cityDidChanges: ((Bool, Bool) -> Void)? { get set }
    func fetchCitiesList()
}

class CityViewModel
{

    var cityDidChanges: ((Bool, Bool) -> Void)?
    var cities: [List]? {
        didSet {
            self.cityDidChanges?(true, false)
        }
    }
    
    func fetchCitiesList(cityName:String) {
        self.cities = [List]()
//         CitiesList.shared.Getcities(with: ["country":cityName]) { (response) in
//             print(response)
//             self.cities = response.data
//         } onFailure: { error in
//
//         }
        
        CitiesList.shared.getWeatherDetails(with:cityName) { response in
            self.cities = response.list
        } onFailure: { error in
            
        }
    }
    

}
