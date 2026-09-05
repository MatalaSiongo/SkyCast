//
//  AirQualityResponse.swift
//  SkyCast
//
//  Created by Matala on 2026-09-05.
//
import Foundation

struct AirQualityResponse: Codable {
    let current: CurrentAirQuality
}

struct CurrentAirQuality: Codable {
    let europeanAqi: Int

    enum CodingKeys: String, CodingKey {
        case europeanAqi = "european_aqi"
    }
}
