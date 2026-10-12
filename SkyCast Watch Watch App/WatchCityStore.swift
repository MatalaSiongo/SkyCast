//
//  WatchCityStore.swift
//  SkyCast Watch Watch App
//
//  Created by Matala on 2026-10-10.
 
import Foundation
import Combine

@MainActor
final class WatchCityStore: ObservableObject {

    @Published private(set) var savedCities: [String] = []
    @Published var selectedCity: String = "Gothenburg"

    private let citiesKey = "skycast_watch_saved_cities"
    private let selectedCityKey = "skycast_watch_selected_city"

    init() {
        let storedCities = UserDefaults.standard.stringArray(
            forKey: citiesKey
        ) ?? ["Gothenburg"]

        savedCities = storedCities.isEmpty
            ? ["Gothenburg"]
            : storedCities

        let storedSelection = UserDefaults.standard.string(
            forKey: selectedCityKey
        ) ?? "Gothenburg"

        selectedCity = storedSelection
    }

    func selectCity(_ city: String) {
        selectedCity = city

        UserDefaults.standard.set(
            city,
            forKey: selectedCityKey
        )
    }

    func addCity(_ city: String) {
        let cleaned = city.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleaned.isEmpty else {
            return
        }

        if !savedCities.contains(
            where: { $0.localizedCaseInsensitiveCompare(cleaned) == .orderedSame }
        ) {
            savedCities.append(cleaned)
            saveCities()
        }

        selectCity(cleaned)
    }

    func removeCity(_ city: String) {
        savedCities.removeAll { $0 == city }

        if savedCities.isEmpty {
            savedCities = ["Gothenburg"]
        }

        saveCities()

        if selectedCity == city {
            selectCity(savedCities[0])
        }
    }

    private func saveCities() {
        UserDefaults.standard.set(
            savedCities,
            forKey: citiesKey
        )
    }
}

