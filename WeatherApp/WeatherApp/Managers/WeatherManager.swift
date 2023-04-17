//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Juan Bazan Carrizo on 07/04/2023.
//

import Foundation
import CoreLocation

enum HttpError: Error {
    case badURL, badResponse, errorDecodingData, invalidURL
}
class WeatherManager {
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody {
        
        let urlString =  "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=d33122997fd1bfb3b64dfaccd378a366"
        
        guard let url = URL(string: urlString) else {
            throw HttpError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw HttpError.badResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let responseBody = try? decoder.decode(ResponseBody.self, from: data) else {
            throw HttpError.errorDecodingData
        }
        
        return responseBody
    }
}

enum CodingKeys: CodingKey {
    case coord, weather, main, name, wind
}

class ResponseBody: Decodable, ObservableObject {
    @Published var coord: CoordinatesResponse
    @Published var weather: [WeatherResponse]
    @Published var main: MainResponse
    @Published var name: String
    @Published var wind: WindResponse
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        coord = try container.decode(CoordinatesResponse.self, forKey: .coord)
        weather = try container.decode([WeatherResponse].self, forKey: .weather)
        main = try container.decode(MainResponse.self, forKey: .main)
        name = try container.decode(String.self, forKey: .name)
        wind = try container.decode(WindResponse.self, forKey: .wind)
    }
}

struct CoordinatesResponse: Decodable {
    let lon: Double
    let lat: Double
}

struct WeatherResponse: Decodable {
    let id: Double
    let main: String
    let description: String
    let icon: String
}

struct MainResponse: Decodable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let humidity: Double
}

struct WindResponse: Decodable {
    let speed: Double
    let deg: Double
}

extension MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}

