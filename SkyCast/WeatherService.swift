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

    func fetchWeather(for city: String) async throws -> WeatherResponse {

        // Temporary debugging
        print("API key empty:", apiKey.isEmpty)
        print("API key placeholder:", apiKey == "$(OPENWEATHER_API_KEY)")

        guard !apiKey.isEmpty else {
            print("ERROR: OpenWeather API key is missing.")
            throw URLError(.userAuthenticationRequired)
        }

        let cityName = city.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? city

        let urlString =
            "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status:", httpResponse.statusCode)
        }

        print(
            "API Response:",
            String(data: data, encoding: .utf8) ?? "Unable to read response"
        )

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let weatherResponse = try JSONDecoder().decode(
            WeatherResponse.self,
            from: data
        )

        return weatherResponse
    }
}
