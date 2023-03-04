//
//  Network+Weather.swift
//  SecondHand
//
//  Created by Fabian Kuschke on 04.03.23.
//

import Foundation
import Alamofire


private let apiKey = "a6b243f000737fa523434d1e8fc4d1a7"

// MARK: - OpenWeather URLs

let dailyUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=\(apiKey)&units=metric&lang=en"


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
        return "Маx. \(maxTemp), Min. \(minTemp)"
    }
}





func fetchWeather (lat: Double, lon: Double, success: @escaping (_ str: String) -> Void, failure: @escaping (_ error: String) -> Void){
    let locatedDailyUrl = URL(string: dailyUrl + "&lon=\(lon)&lat=\(lat)")
    let session = URLSession.shared
    let request = URLRequest(url: locatedDailyUrl!)
          
     let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
         guard error == nil else {
             return
         }
         guard let data = data else {
             return
         }
              
        do {
            let weather = try JSONDecoder().decode(DailyWeather.self, from: data)
            let temp = Double(round(10 * weather.main.temp) / 10)
            let tempStr = "\(temp) Grad"
            success(tempStr)
        } catch let error {
          print("malle error ",error.localizedDescription)
        }
     })
     task.resume()

}
