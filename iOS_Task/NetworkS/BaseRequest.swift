//
//  BaseRequest.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit
import Alamofire

class BaseRequest: NSObject {
    
    func postJsonData(with requestType: RequestType, parameters : Parameters, onSuccess : @escaping(Data)->(), onFailure : @escaping (String)->())  {
      
        let headers = [
                       "Content-Type": "application/json"]
        
        let data = try? JSONSerialization.data(withJSONObject:parameters)
        
        let requestUrlString = "\(requestType.rawValue)"
        if let url = URL.init(string:requestUrlString.replacingOccurrences(of: " ", with: "%20") ) {
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.httpBody = data
            request.allHTTPHeaderFields = headers
            Alamofire.request(request).responseString { response in
                
                print("Response - \(response)")
                switch response.result {
                case .success(_):
                    //                print("success : \(response.data)")
                    onSuccess(response.data!)
                    break
                case .failure(let error):
                    onFailure(error.localizedDescription)
                    break
                    
                }
            }
        }
    }
    

        
    func getJsonData(with requestType : RequestType, cityName : String, onSuccess : @escaping(Data)->(), onFailure : @escaping(String)->()) {
        
       
        let headers = [
                       "Content-Type": "application/json"]
       
        let requestUrlString : String?
            requestUrlString =
        "\(requestType.rawValue)?bbox=12,32,15,37,10&appid=\(remoteConfig.APPID)&q=\(cityName)"
            
        Alamofire.request(requestUrlString!, method: .get, parameters: [:], encoding: URLEncoding.default, headers: headers).responseString { response in
            print("Response - \(response)")
            switch response.result {
            case .success(_):
                
                onSuccess(response.data!)
                break
            case .failure(let error):
                onFailure(error.localizedDescription)
                break

            }
        }
    }
    
   
}
