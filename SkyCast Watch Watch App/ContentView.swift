
import SwiftUI

struct ContentView: View {

    @StateObject private var cityStore = WatchCityStore()

    @State private var weather: WatchWeatherResponse?
    @State private var hourlyForecast: WatchHourlyForecastResponse?
    @State private var isLoading = false
    @State private var isForecastLoading = false
    @State private var errorMessage: String?
    @State private var forecastError = false
    @State private var showingCities = false

    private let weatherService = WatchWeatherService()

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                header

                if let weather {
                    currentWeather(weather)
                    hourlySection
                    detailsSection(weather)
                } else if isLoading {
                    ProgressView("Loading weather...")
                        .font(.caption)
                        .padding(.vertical, 25)
                } else if let errorMessage {
                    errorSection(errorMessage)
                } else {
                    Text("Welcome to SkyCast")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                refreshButton
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
        }
        .background(backgroundGradient)
        .sheet(isPresented: $showingCities) {
            WatchCitiesView(cityStore: cityStore)
        }
        .task(id: cityStore.selectedCity) {
            weather = nil
            hourlyForecast = nil
            errorMessage = nil
            await loadWeather()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4) {

            Button {
                showingCities = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundStyle(.blue)

                    Text(weather?.name ?? cityStore.selectedCity)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            Text(Date.now.formatted(.dateTime.weekday(.wide)))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Current Weather

    private func currentWeather(
        _ weather: WatchWeatherResponse
    ) -> some View {

        let condition = weather.weather.first

        return VStack(spacing: 6) {

            Image(
                systemName: weatherSymbol(
                    for: condition?.icon ?? ""
                )
            )
            .symbolRenderingMode(.multicolor)
            .font(.system(size: 38))

            Text("\(Int(weather.main.temp.rounded()))°")
                .font(.system(size: 44, weight: .thin))
                .minimumScaleFactor(0.8)

            Text(
                (condition?.description ?? "Weather").capitalized
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                Text("H: \(Int(weather.main.tempMax.rounded()))°")
                Text("L: \(Int(weather.main.tempMin.rounded()))°")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Text(
                "Feels like \(Int(weather.main.feelsLike.rounded()))°"
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        }
    }

    // MARK: - Hourly Forecast

    private var hourlySection: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("Next Hours")
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                if isForecastLoading {
                    ProgressView()
                        .controlSize(.mini)
                }
            }

            if let hourlyForecast {

                let items = forecastItems(from: hourlyForecast)

                if items.isEmpty {
                    Text("No hourly forecast available")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(items) { item in
                                VStack(spacing: 6) {

                                    Text(item.time)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)

                                    Image(
                                        systemName: forecastSymbol(
                                            for: item.weatherCode
                                        )
                                    )
                                    .symbolRenderingMode(.multicolor)
                                    .font(.title3)

                                    Text(
                                        "\(Int(item.temperature.rounded()))°"
                                    )
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                }
                                .frame(width: 43)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

            } else if isForecastLoading {
                Text("Loading hourly forecast...")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

            } else if forecastError {
                Text("Hourly forecast unavailable")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

            } else {
                Text("Hourly forecast not loaded")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        }
    }

    // MARK: - Convert Forecast Data

    private func forecastItems(
        from response: WatchHourlyForecastResponse
    ) -> [WatchHourlyItem] {

        let hourly = response.hourly

        let count = min(
            hourly.time.count,
            hourly.temperature.count,
            hourly.weatherCode.count,
            12
        )

        guard count > 0 else {
            return []
        }

        return (0..<count).map { index in

            let rawTime = hourly.time[index]
            let displayTime: String

            if index == 0 {
                displayTime = "Now"
            } else if let timePart = rawTime.split(
                separator: "T"
            ).last {
                displayTime = String(timePart.prefix(5))
            } else {
                displayTime = rawTime
            }

            return WatchHourlyItem(
                index: index,
                time: displayTime,
                temperature: hourly.temperature[index],
                weatherCode: hourly.weatherCode[index]
            )
        }
    }

    // MARK: - Weather Details

    private func detailsSection(
        _ weather: WatchWeatherResponse
    ) -> some View {

        HStack(spacing: 8) {

            WeatherDetail(
                icon: "humidity.fill",
                value: "\(weather.main.humidity)%",
                title: "Humidity"
            )

            WeatherDetail(
                icon: "wind",
                value: String(
                    format: "%.0f",
                    weather.wind.speed * 3.6
                ),
                title: "km/h"
            )
        }
    }

    // MARK: - Errors

    private func errorSection(
        _ message: String
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "wifi.exclamationmark")
                .font(.title2)
                .foregroundStyle(.orange)

            Text("Unable to load weather")
                .font(.caption)
                .fontWeight(.semibold)

            Text(message)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Refresh

    private var refreshButton: some View {
        Button {
            Task {
                await loadWeather()
            }
        } label: {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .controlSize(.mini)
                } else {
                    Image(systemName: "arrow.clockwise")
                }

                Text(isLoading ? "Refreshing..." : "Refresh")
            }
            .font(.caption)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        .disabled(isLoading)
    }

    // MARK: - Fetch Live Weather

    @MainActor
    private func loadWeather() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        let requestedCity = cityStore.selectedCity

        defer {
            isLoading = false
        }

        do {
            let result = try await weatherService.fetchWeather(
                for: requestedCity
            )

            guard requestedCity == cityStore.selectedCity else {
                return
            }

            weather = result

            print(
                "⌚️ Weather loaded:",
                result.name,
                result.main.temp
            )

            await loadHourlyForecast(
                latitude: result.coord.lat,
                longitude: result.coord.lon,
                for: requestedCity
            )

        } catch {
            guard requestedCity == cityStore.selectedCity else {
                return
            }

            if weather == nil {
                errorMessage = error.localizedDescription
            }

            print(
                "❌ Watch weather error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Fetch Hourly Forecast

    @MainActor
    private func loadHourlyForecast(
        latitude: Double,
        longitude: Double,
        for requestedCity: String
    ) async {

        isForecastLoading = true
        forecastError = false

        defer {
            isForecastLoading = false
        }

        do {
            let result = try await weatherService.fetchHourlyForecast(
                latitude: latitude,
                longitude: longitude
            )

            guard requestedCity == cityStore.selectedCity else {
                return
            }

            hourlyForecast = result

            print(
                "⌚️ Hourly forecast loaded:",
                result.hourly.time.count,
                "hours"
            )

        } catch {
            guard requestedCity == cityStore.selectedCity else {
                return
            }

            forecastError = true

            print(
                "❌ Watch hourly forecast error:",
                error.localizedDescription
            )
        }
    }

    // MARK: - Current Weather Symbols

    private func weatherSymbol(
        for iconCode: String
    ) -> String {
        switch iconCode {
        case "01d":
            return "sun.max.fill"
        case "01n":
            return "moon.stars.fill"
        case "02d":
            return "cloud.sun.fill"
        case "02n":
            return "cloud.moon.fill"
        case "03d", "03n", "04d", "04n":
            return "cloud.fill"
        case "09d", "09n":
            return "cloud.drizzle.fill"
        case "10d":
            return "cloud.sun.rain.fill"
        case "10n":
            return "cloud.moon.rain.fill"
        case "11d", "11n":
            return "cloud.bolt.rain.fill"
        case "13d", "13n":
            return "cloud.snow.fill"
        case "50d", "50n":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }

    // MARK: - Forecast Weather Symbols

    private func forecastSymbol(
        for code: Int
    ) -> String {
        switch code {
        case 0:
            return "sun.max.fill"
        case 1, 2:
            return "cloud.sun.fill"
        case 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55, 56, 57:
            return "cloud.drizzle.fill"
        case 61, 63, 65, 66, 67, 80, 81, 82:
            return "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86:
            return "cloud.snow.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.35),
                Color.cyan.opacity(0.15),
                Color.black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Hourly Forecast Item

private struct WatchHourlyItem: Identifiable {
    let index: Int
    let time: String
    let temperature: Double
    let weatherCode: Int

    var id: Int { index }
}

// MARK: - Weather Detail Card

struct WeatherDetail: View {

    let icon: String
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {

            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)

            Text(title)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    ContentView()
}

