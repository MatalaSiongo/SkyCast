//
//  WeatherViewModel.swift
//  SkyCast
//
//  Created by Matala on 2026-08-31.
//
import SwiftUI
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {

    @Published var weather: WeatherResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let weatherService = WeatherService()

    func fetchWeather(for city: String) async {
        isLoading = true
        errorMessage = nil

        do {
            weather = try await weatherService.fetchWeather(for: city)
        } catch {
            errorMessage = "Could not load weather data."
        }

        isLoading = false
    }
}
