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

        let cityName = city.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? city

        let urlString =
            "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            throw URLError(.badURL)
        }

        print("Requesting weather for:", city)

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("No HTTP response")
            throw URLError(.badServerResponse)
        }

        print("HTTP Status:", httpResponse.statusCode)

        if let responseText = String(data: data, encoding: .utf8) {
            print("API Response:", responseText)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        do {
            return try JSONDecoder().decode(
                WeatherResponse.self,
                from: data
            )
        } catch {
            print("Decoding error:", error)
            throw error
        }
    }
}
