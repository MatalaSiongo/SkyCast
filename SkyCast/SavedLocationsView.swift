//
//  SavedLocationsView.swift
//  SkyCast
//
//  Created by Matala on 2026-09-05.
//

import SwiftUI

struct SavedLocationsView: View {

    @State private var savedCities: [String] = []
    @State private var newCity = ""

    let onSelectCity: (String) -> Void

    private let storageKey = "savedWeatherCities"

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [
                    Color.blue.opacity(0.95),
                    Color.cyan.opacity(0.75),
                    Color.indigo.opacity(0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 18) {

                    header

                    addCityBar

                    if savedCities.isEmpty {

                        emptyState

                    } else {

                        VStack(spacing: 12) {

                            ForEach(savedCities, id: \.self) { city in

                                SavedCityCard(
                                    city: city,
                                    onSelect: {
                                        onSelectCity(city)
                                    },
                                    onDelete: {
                                        deleteCity(city)
                                    }
                                )
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .onAppear {
            loadCities()
        }
    }
}


// MARK: - Header

private extension SavedLocationsView {

    var header: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Locations")
                .font(
                    .system(
                        size: 38,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)

            Text("Save cities for quick access")
                .font(.subheadline)
                .foregroundStyle(
                    .white.opacity(0.75)
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 4)
    }
}


// MARK: - Add City

private extension SavedLocationsView {

    var addCityBar: some View {

        HStack(spacing: 12) {

            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.white)

            TextField(
                "Add city...",
                text: $newCity
            )
            .foregroundStyle(.white)
            .submitLabel(.done)
            .onSubmit {
                addCity()
            }

            Button {
                addCity()
            } label: {
                Image(
                    systemName: "arrow.down.circle.fill"
                )
                .font(.title2)
                .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 22
            )
            .stroke(
                .white.opacity(0.28),
                lineWidth: 1
            )
        )
    }

    func addCity() {

        let trimmedCity =
            newCity.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedCity.isEmpty else {
            return
        }

        let alreadyExists =
            savedCities.contains {
                $0.caseInsensitiveCompare(
                    trimmedCity
                ) == .orderedSame
            }

        guard !alreadyExists else {
            newCity = ""
            return
        }

        savedCities.append(trimmedCity)
        saveCities()

        newCity = ""
    }
}


// MARK: - Empty State

private extension SavedLocationsView {

    var emptyState: some View {

        VStack(spacing: 16) {

            Image(
                systemName:
                    "location.circle.fill"
            )
            .font(
                .system(size: 64)
            )

            Text("No saved locations")
                .font(.title2.bold())

            Text(
                "Add a city above and it will stay saved here."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(
                .white.opacity(0.75)
            )
        }
        .foregroundStyle(.white)
        .padding(.top, 90)
        .padding(.horizontal, 30)
    }
}


// MARK: - Persistence

private extension SavedLocationsView {

    func loadCities() {

        savedCities =
            UserDefaults.standard
                .stringArray(
                    forKey: storageKey
                )
            ?? [
                "Stockholm",
                "London",
                "Los Angeles"
            ]
    }

    func saveCities() {

        UserDefaults.standard.set(
            savedCities,
            forKey: storageKey
        )
    }

    func deleteCity(
        _ city: String
    ) {

        savedCities.removeAll {
            $0 == city
        }

        saveCities()
    }
}


// MARK: - Saved City Card

struct SavedCityCard: View {

    let city: String
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {

        HStack(spacing: 14) {

            Button(
                action: onSelect
            ) {

                HStack(spacing: 14) {

                    ZStack {

                        Circle()
                            .fill(
                                .white.opacity(0.12)
                            )
                            .frame(
                                width: 48,
                                height: 48
                            )

                        Image(
                            systemName:
                                "location.fill"
                        )
                        .foregroundStyle(.white)
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(city)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("Tap to view weather")
                            .font(.caption)
                            .foregroundStyle(
                                .white.opacity(0.7)
                            )
                    }

                    Spacer()

                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .foregroundStyle(
                        .white.opacity(0.7)
                    )
                }
            }
            .buttonStyle(.plain)

            Button(
                action: onDelete
            ) {

                Image(
                    systemName:
                        "trash.fill"
                )
                .foregroundStyle(
                    .red.opacity(0.9)
                )
                .frame(
                    width: 40,
                    height: 40
                )
                .background(
                    .white.opacity(0.10)
                )
                .clipShape(
                    Circle()
                )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            .ultraThinMaterial
        )
        .background(
            .white.opacity(0.05)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 24
            )
            .stroke(
                .white.opacity(0.22),
                lineWidth: 1
            )
        )
    }
}


#Preview {

    SavedLocationsView { city in
        print("Selected:", city)
    }
}
