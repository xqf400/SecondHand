//
//  Public.swift
//  SecondHand
//
//  Created by Fabian Kuschke on 04.03.23.
//

import Foundation
import Alamofire

private let apiKey = "a6b243f000737fa523434d1e8fc4d1a7"

// MARK: - OpenWeather URLs

let dailyUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=\(apiKey)&units=metric&lang=en"


var networkManager = Network()

struct DailyWeatherMain: Codable {
    let temp: Double
    let feels_like: Double
    let humidity: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
}

struct DailyWeather: Codable {
    let main: DailyWeatherMain
    let name: String
    let weather: [WeatherDescription]
    let wind: Wind
    let visibility: Int
}
struct WeatherDescription: Codable {
    let description: String
    let id: Int
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
}

struct DailyWeatherModel {
    let cityName: String
    let temperature: String
    let description: String
    let maxTemp: String
    let minTemp: String
    let feelsLike: Double
    let humidity: Double
    let id: String
    let visibility: Int
    let pressure: Int
    let windSpeed: Double
    var minMaxTemp: String {
        return "Макс. \(maxTemp), мин. \(minTemp)"
    }
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: DailyWeatherModel)
}

final class Network {
    var delegate: WeatherManagerDelegate?
    var weather: DailyWeather?
    
    // MARK: - Put coordinates in URL
    
    func fetchLocationForUrl (lon: Double, lat: Double) {
        let locatedDailyUrl = dailyUrl + "&lon=\(lon)&lat=\(lat)"
        makeRequest(url: locatedDailyUrl)
    }
    
    // MARK: - Make weather request
    
    func makeRequest (url: String) {
        AF.request(url).responseDecodable(of: DailyWeather.self) { [weak self] response in
            switch response.result {
            case .success(let value):
                print("value: \(value)")
                self?.weather = value
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
