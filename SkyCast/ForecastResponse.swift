//
//  ForecastResponse.swift
//  SkyCast
//
//  Created by Matala on 2026-09-05.
//
import Foundation

struct ForecastResponse: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let hourly: HourlyForecastData
    let daily: DailyForecastData
}

struct HourlyForecastData: Codable {
    let time: [String]
    let temperature2m: [Double]
    let apparentTemperature: [Double]
    let precipitationProbability: [Int]
    let weatherCode: [Int]
    let windSpeed10m: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case precipitationProbability = "precipitation_probability"
        case weatherCode = "weather_code"
        case windSpeed10m = "wind_speed_10m"
    }
}

struct DailyForecastData: Codable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationProbabilityMax: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax =
            "precipitation_probability_max"
    }
}
