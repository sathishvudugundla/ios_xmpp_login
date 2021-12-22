//
//  WeatherModel.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import Foundation
//List(id: <#T##Int#>, name: <#T##String#>, coord: <#T##Coord#>, main: <#T##MainClass#>, visibility: <#T##Int#>, wind: <#T##Wind#>, clouds: <#T##Clouds#>, weather: <#T##[Weather]#>)
    struct WeatherModel: Codable {
        var cod: Int
        var calctime: Double
        var cnt: Int
        var list: [List]
    }

    // MARK: - List
    struct List: Codable {
        var id, dt: Int?
        var name: String?
        var coord: Coord?
        var main: MainClass?
        var visibility: Int
        var wind: Wind?
        var rain, snow: JSONNull?
        var clouds: Clouds?
        var weather: [Weather]?
    }

    // MARK: - Clouds
    struct Clouds: Codable {
        let today: Int
    }

    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double

        enum CodingKeys: String, CodingKey {
            case lon = "Lon"
            case lat = "Lat"
        }
    }

    // MARK: - MainClass
    struct MainClass: Codable {
        let temp, feelsLike, tempMin, tempMax: Double?
        let pressure, humidity: Int?
        let seaLevel, grndLevel: Int?

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
            case seaLevel = "sea_level"
            case grndLevel = "grnd_level"
        }
    }

    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main: MainEnum
        let weatherDescription, icon: String

        enum CodingKeys: String, CodingKey {
            case id, main
            case weatherDescription = "description"
            case icon
        }
    }

    enum MainEnum: String, Codable {
        case clear = "Clear"
        case clouds = "Clouds"
    }

    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }

    // MARK: - Encode/decode helpers

    class JSONNull: Codable, Hashable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }

        public var hashValue: Int {
            return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

