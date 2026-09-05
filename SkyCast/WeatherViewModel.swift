//
//  WeatherViewModel.swift
//  SkyCast
//
//  Created by Matala on 2026-08-31.
import SwiftUI
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {

    @Published var weather: WeatherResponse?
    @Published var forecast: ForecastResponse?
    @Published var airQuality: AirQualityResponse?

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let weatherService = WeatherService()

    func fetchWeather(for city: String) async {

        let trimmedCity =
            city.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedCity.isEmpty else {
            return
        }

        isLoading = true
        errorMessage = nil

        do {

            let current =
                try await weatherService.fetchWeather(
                    for: trimmedCity
                )

            weather = current

            async let forecastRequest =
                weatherService.fetchForecast(
                    latitude: current.coord.lat,
                    longitude: current.coord.lon
                )

            async let airQualityRequest =
                weatherService.fetchAirQuality(
                    latitude: current.coord.lat,
                    longitude: current.coord.lon
                )

            forecast = try await forecastRequest
            airQuality = try await airQualityRequest

        } catch {

            errorMessage =
                "Could not load weather data."
        }

        isLoading = false
    }
}
