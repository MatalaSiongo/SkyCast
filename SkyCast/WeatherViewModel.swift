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
    @Published var cityImage: CityImage?

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let weatherService = WeatherService()
    private let cityImageService = CityImageService()

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

        // Prevent the previous city's photo from remaining
        // while a new city is loading.
        cityImage = nil

        // MARK: Current Weather

        let current: WeatherResponse

        do {

            current =
                try await weatherService.fetchWeather(
                    for: trimmedCity
                )

            weather = current

        } catch {

            print(
                "❌ Current weather error:",
                error
            )

            errorMessage =
                "Could not load weather data."

            isLoading = false

            return
        }

        // MARK: Forecast

        do {

            forecast =
                try await weatherService.fetchForecast(
                    latitude: current.coord.lat,
                    longitude: current.coord.lon
                )

        } catch {

            print(
                "⚠️ Forecast error:",
                error
            )

            forecast = nil
        }

        // MARK: Air Quality

        do {

            airQuality =
                try await weatherService.fetchAirQuality(
                    latitude: current.coord.lat,
                    longitude: current.coord.lon
                )

        } catch {

            print(
                "⚠️ Air quality error:",
                error
            )

            airQuality = nil
        }

        // MARK: City Background

        do {

            cityImage =
                try await cityImageService.fetchCityImage(
                    for: current.name
                )

            if let cityImage {

                print(
                    "✅ City image loaded:",
                    cityImage.imageURL
                )

            } else {

                print(
                    "⚠️ Pexels returned no city image."
                )
            }

        } catch {

            print(
                "⚠️ Pexels city image error:",
                error
            )

            cityImage = nil
        }

        isLoading = false
    }
}
