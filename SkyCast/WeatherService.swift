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

    // MARK: - Current Weather

    func fetchWeather(
        for city: String
    ) async throws -> WeatherResponse {

        guard !apiKey.isEmpty else {
            print("❌ OpenWeather API key is empty.")
            throw URLError(.userAuthenticationRequired)
        }

        var components = URLComponents(
            string: "https://api.openweathermap.org/data/2.5/weather"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "q",
                value: city
            ),
            URLQueryItem(
                name: "appid",
                value: apiKey
            ),
            URLQueryItem(
                name: "units",
                value: "metric"
            )
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await URLSession.shared.data(
                from: url
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw URLError(.badServerResponse)
        }

        print(
            "🌤️ OpenWeather HTTP status:",
            httpResponse.statusCode
        )

        guard httpResponse.statusCode == 200 else {

            if let serverMessage =
                String(
                    data: data,
                    encoding: .utf8
                ) {

                print(
                    "❌ OpenWeather response:",
                    serverMessage
                )
            }

            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            WeatherResponse.self,
            from: data
        )
    }

    // MARK: - Forecast

    func fetchForecast(
        latitude: Double,
        longitude: Double
    ) async throws -> ForecastResponse {

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
                value:
                    "temperature_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m"
            ),
            URLQueryItem(
                name: "daily",
                value:
                    "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
            ),
            URLQueryItem(
                name: "timezone",
                value: "auto"
            ),
            URLQueryItem(
                name: "forecast_days",
                value: "7"
            )
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await URLSession.shared.data(
                from: url
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {

            print(
                "❌ Forecast HTTP status:",
                httpResponse.statusCode
            )

            if let serverMessage =
                String(
                    data: data,
                    encoding: .utf8
                ) {

                print(
                    "❌ Forecast response:",
                    serverMessage
                )
            }

            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            ForecastResponse.self,
            from: data
        )
    }

    // MARK: - Air Quality

    func fetchAirQuality(
        latitude: Double,
        longitude: Double
    ) async throws -> AirQualityResponse {

        var components = URLComponents(
            string:
                "https://air-quality-api.open-meteo.com/v1/air-quality"
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
                name: "current",
                value: "european_aqi"
            )
        ]

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) =
            try await URLSession.shared.data(
                from: url
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {

            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {

            print(
                "❌ Air quality HTTP status:",
                httpResponse.statusCode
            )

            if let serverMessage =
                String(
                    data: data,
                    encoding: .utf8
                ) {

                print(
                    "❌ Air quality response:",
                    serverMessage
                )
            }

            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            AirQualityResponse.self,
            from: data
        )
    }
}
