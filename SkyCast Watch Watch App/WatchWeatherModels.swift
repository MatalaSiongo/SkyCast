//
//  WatchWeatherModels.swift
//  SkyCast Watch Watch App
//
//  Created by Matala on 2026-09-09.
//
import Foundation

struct WatchWeatherResponse: Codable {
    let coord: WatchCoordinates
    let name: String
    let main: WatchMainWeather
    let weather: [WatchWeatherCondition]
    let wind: WatchWind
}

struct WatchCoordinates: Codable {
    let lon: Double
    let lat: Double
}

struct WatchMainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    let tempMin: Double
    let tempMax: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct WatchWeatherCondition: Codable {
    let main: String
    let description: String
    let icon: String
}

struct WatchWind: Codable {
    let speed: Double
}
