//
//  CityModel.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import Foundation

struct CityModel: Codable {
    let error: Bool
    let msg: String
    let data: [String]
}

// MARK: - Datum
struct Datum: Codable {
    let name, code, dialCode: String

    enum CodingKeys: String, CodingKey {
        case name, code
        case dialCode = "dial_code"
    }
}
