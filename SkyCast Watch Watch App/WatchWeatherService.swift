
//
//  WatchWeatherService.swift
//  SkyCast Watch Watch App
//

import Foundation

final class WatchWeatherService {

    private var apiKey: String {
        Bundle.main.object(
            forInfoDictionaryKey: "OPENWEATHER_API_KEY"
        ) as? String ?? ""
    }

    // MARK: - Current Weather

    func fetchWeather(
        for city: String
    ) async throws -> WatchWeatherResponse {

        guard !apiKey.isEmpty,
              !apiKey.contains("$(") else {
            print("❌ Watch OpenWeather API key is missing.")
            throw URLError(.userAuthenticationRequired)
        }

        var components = URLComponents(
            string: "https://api.openweathermap.org/data/2.5/weather"
        )

        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print(
            "⌚️ OpenWeather HTTP status:",
            httpResponse.statusCode
        )

        guard httpResponse.statusCode == 200 else {
            if let serverMessage = String(
                data: data,
                encoding: .utf8
            ) {
                print(
                    "❌ Watch OpenWeather response:",
                    serverMessage
                )
            }

            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            WatchWeatherResponse.self,
            from: data
        )
    }

    // MARK: - Hourly Forecast

    func fetchHourlyForecast(
        latitude: Double,
        longitude: Double
    ) async throws -> WatchHourlyForecastResponse {

        var components = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "latitude",
                value: String(latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(longitude)
            ),
            URLQueryItem(
                name: "hourly",
                value: "temperature_2m,weather_code"
            ),
            URLQueryItem(
                name: "forecast_hours",
                value: "12"
            ),
            URLQueryItem(
                name: "timezone",
                value: "auto"
            )
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print(
            "⌚️ Open-Meteo HTTP status:",
            httpResponse.statusCode
        )

        guard httpResponse.statusCode == 200 else {
            if let serverMessage = String(
                data: data,
                encoding: .utf8
            ) {
                print(
                    "❌ Watch forecast response:",
                    serverMessage
                )
            }

            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            WatchHourlyForecastResponse.self,
            from: data
        )
    }
}

// MARK: - Hourly Forecast Models

struct WatchHourlyForecastResponse: Decodable {
    let hourly: WatchHourlyForecastData
}

struct WatchHourlyForecastData: Decodable {
    let time: [String]
    let temperature: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

