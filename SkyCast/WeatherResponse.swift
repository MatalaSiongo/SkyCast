//
//  WeatherResponse.swift
//  SkyCast
//
//  Created by Matala on 2026-08-20.
//
import Foundation

struct WeatherResponse: Codable {
    let coord: Coordinates
    let name: String
    let main: MainWeather
    let weather: [WeatherCondition]
    let wind: Wind
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct MainWeather: Codable {
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

struct WeatherCondition: Codable {
    let main: String
    let description: String
    let icon: String
}

struct Wind: Codable {
    let speed: Double
}
