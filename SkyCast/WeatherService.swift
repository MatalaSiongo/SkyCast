//
//  WeatherService.swift
//  SkyCast
//
//  Created by Matala on 2026-08-20.
import Foundation

final class WeatherService {

    private var apiKey: String {
        Bundle.main.object(
            forInfoDictionaryKey: "OPENWEATHER_API_KEY"
        ) as? String ?? ""
    }

    func fetchWeather(
        for city: String
    ) async throws -> WeatherResponse {

        let cityName =
            city.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) ?? city

        let urlString =
            "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await URLSession.shared.data(from: url)

        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            WeatherResponse.self,
            from: data
        )
    }

    func fetchForecast(
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {

        let urlString =
        """
        https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&forecast_days=7
        """

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await URLSession.shared.data(from: url)

        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            ForecastResponse.self,
            from: data
        )
    }

    func fetchAirQuality(
        latitude: Double,
        longitude: Double
    ) async throws -> AirQualityResponse {

        let urlString =
        """
        https://air-quality-api.open-meteo.com/v1/air-quality?latitude=\(latitude)&longitude=\(longitude)&current=european_aqi
        """

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await URLSession.shared.data(from: url)

        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            AirQualityResponse.self,
            from: data
        )
    }
}
