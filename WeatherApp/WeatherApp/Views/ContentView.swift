//
//  ContentView.swift
//  WeatherApp
//
//  Created by Juan Bazan Carrizo on 31/03/2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var locationManager = LocationManager()
    @State var weatherModel: ResponseBody?
    let weatherManager = WeatherManager()
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                if let weather = weatherModel {
                    WeatherView(weatherModel: weather)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task {
                            do {
                                weatherModel = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                }
            } else {
                if locationManager.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }  
        }
        
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
