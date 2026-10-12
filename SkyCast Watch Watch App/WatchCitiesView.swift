//
//  WatchCitiesView.swift
//  SkyCast Watch Watch App
//
//  Created by Matala on 2026-10-10.
//

import SwiftUI

struct WatchCitiesView: View {

    @ObservedObject var cityStore: WatchCityStore

    let weatherService = WatchWeatherService()

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var errorMessage: String?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {

            Section("Saved Cities") {
                ForEach(cityStore.savedCities, id: \.self) { city in
                    Button {
                        cityStore.selectCity(city)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.cyan)

                            Text(city)
                                .lineLimit(1)

                            Spacer()

                            if city == cityStore.selectedCity {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteCities)
            }

            Section {
                TextField("Search city", text: $searchText)

                Button {
                    Task {
                        await searchAndAddCity()
                    }
                } label: {
                    HStack {
                        if isSearching {
                            ProgressView()
                        } else {
                            Image(systemName: "plus.circle.fill")
                        }

                        Text(isSearching ? "Searching..." : "Add City")
                    }
                }
                .disabled(
                    searchText.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty || isSearching
                )
            } header: {
                Text("Add New City")
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Cities")
    }

    private func deleteCities(at offsets: IndexSet) {
        let citiesToRemove = offsets.map {
            cityStore.savedCities[$0]
        }

        for city in citiesToRemove {
            cityStore.removeCity(city)
        }
    }

    @MainActor
    private func searchAndAddCity() async {
        let city = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !city.isEmpty else { return }

        isSearching = true
        errorMessage = nil

        defer {
            isSearching = false
        }

        do {
            let result = try await weatherService.fetchWeather(
                for: city
            )

            cityStore.addCity(result.name)
            searchText = ""
            dismiss()

        } catch {
            errorMessage = "City not found or network unavailable."
        }
    }
}

#Preview {
    NavigationStack {
        WatchCitiesView(cityStore: WatchCityStore())
    }
}

