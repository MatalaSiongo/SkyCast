//
//  WeatherService.swift
//  SkyCast
//
//  Created by Matala on 2026-08-20.
import Foundation

final class WeatherService {
    
    private let apiKey = "YOUR_API_KEY"
    
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        
        let cityName = city.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        ) ?? city
        
        let urlString =
            "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
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
