//
//  ContentView.swift
//  SecondHand
//
//  Created by lemin on 3/2/23.
//

import SwiftUI

func setTimeSeconds() {
    let calendar = Calendar.current
    let date = Date()
    let hour = calendar.component(.hour, from: date)
    let hourFinal = UserDefaults.standard.bool(forKey: "Time24Hour") ? hour : (hour%12 == 0 ? 12 : hour%12)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    
    let newStr: String = "\(hourFinal):\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    
    if newStr.utf8CString.count <= 64 {
        StatusManager.sharedInstance().setTime(newStr)
    } else {
        StatusManager.sharedInstance().setTime("Length Error")
    }
}

func setCrumbDate() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    
    let newStr: String = dateFormatter.string(from: Date())
    
    if (newStr + " ▶").utf8CString.count <= 256 {
        StatusManager.sharedInstance().setCrumb(newStr)
    } else {
        StatusManager.sharedInstance().setCrumb("Length Error")
    }
}
func setCrumbWeather(str: String) {
    if (str + " ▶").utf8CString.count <= 256 {
        StatusManager.sharedInstance().setCrumb(str)
    } else {
        StatusManager.sharedInstance().setCrumb("Length Error")
    }
}




struct ContentView: View, WeatherManagerDelegate {
    func didUpdateWeather(weather: DailyWeatherModel) {
        setCrumbWeather(str: "test")
    }

    
    @State private var timeTextEnabled: Bool = StatusManager.sharedInstance().isTimeOverridden()
    @State private var crumbTextEnabled: Bool = StatusManager.sharedInstance().isCrumbOverridden()
    @State private var crumbWeatherTextEnabled: Bool = StatusManager.sharedInstance().isCrumbOverridden()
    
    @StateObject var locationDataManager = LocationManager()

    
    //@State private var timeAs24: Bool = UserDefaults.standard.bool(forKey: "Time24Hour")
    
    @ObservedObject var backgroundController = BackgroundFileUpdaterController.shared
    
    @State var test: String = ""
    
    var body: some View {
        VStack {
            Text(timeTextEnabled || crumbTextEnabled || crumbWeatherTextEnabled ? "Running" : "Stopped")
                .foregroundColor(timeTextEnabled || crumbTextEnabled ? .green : .red)
                .font(.title2)
                .padding(20)
            
            // MARK: Configuration
            // MARK: 24-Hour Time
//            Toggle("24 Hour Time", isOn: $timeAs24).onChange(of: timeAs24) { new in
//                UserDefaults.standard.set(new, forKey: "Time24Hour")
//            }
            
            // MARK: Seconds
            Toggle("Seconds", isOn: $timeTextEnabled).onChange(of: timeTextEnabled) { new in
                if new {
                    UserDefaults.standard.set(true, forKey: "TimeIsEnabled")
                    setTimeSeconds()
                    backgroundController.time = 1.0
                    backgroundController.restartTimer()
                    timeTextEnabled = StatusManager.sharedInstance().isTimeOverridden()
                } else {
                    UserDefaults.standard.set(false, forKey: "TimeIsEnabled")
                    backgroundController.time = 3600.0
                    backgroundController.restartTimer()
                    StatusManager.sharedInstance().unsetTime()
                    timeTextEnabled = StatusManager.sharedInstance().isTimeOverridden()
                }
            }
            .padding(10)
            
            // MARK: Date
            Toggle("Date", isOn: $crumbTextEnabled).onChange(of: crumbTextEnabled) { new in
                if new {
                    UserDefaults.standard.set(true, forKey: "DateIsEnabled")
                    setCrumbDate()
                    crumbTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
                } else {
                    UserDefaults.standard.set(false, forKey: "DateIsEnabled")
                    StatusManager.sharedInstance().unsetCrumb()
                    crumbTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
                }
            }
            .padding(10)
            // MARK: Weather
            Toggle("Weather", isOn: $crumbWeatherTextEnabled).onChange(of: crumbWeatherTextEnabled) { new in
                if new {
                    UserDefaults.standard.set(true, forKey: "WeatherIsEnabled")
                    guard let lang = locationDataManager.locationManager.location?.coordinate.latitude else {
                        return
                    }
                    guard let long = locationDataManager.locationManager.location?.coordinate.longitude else {
                        return
                    }
                    networkManager.fetchWeather(lat: lang, lon: long) { str in
                        setCrumbWeather(str: str)
                    } failure: { error in
                        print(error)
                    }
                    crumbWeatherTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
                } else {
                    UserDefaults.standard.set(false, forKey: "WeatherIsEnabled")
                    StatusManager.sharedInstance().unsetCrumb()
                    crumbWeatherTextEnabled = StatusManager.sharedInstance().isCrumbOverridden()
                }
            }
            .padding(10)
            
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "TimeIsEnabled") == true {
                // check if it was disabled elsewhere
                UserDefaults.standard.set(timeTextEnabled, forKey: "TimeIsEnabled")
                if timeTextEnabled == true {
                    backgroundController.time = 1.0
                }
            }
            
            if UserDefaults.standard.bool(forKey: "DateIsEnabled") == true && UserDefaults.standard.bool(forKey: "WeatherIsEnabled") == false{
                // check if it was disabled elsewhere
                UserDefaults.standard.set(crumbTextEnabled, forKey: "DateIsEnabled")
            }
            if UserDefaults.standard.bool(forKey: "WeatherIsEnabled") == true && UserDefaults.standard.bool(forKey: "DateIsEnabled") == false {
                // check if it was disabled elsewhere
                UserDefaults.standard.set(crumbWeatherTextEnabled, forKey: "WeatherIsEnabled")
            }
            networkManager.delegate = self
            

            
            backgroundController.setup()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
