//
//  ContentView.swift
//  SkyCast
//
//  Created by Matala on 2026-08-19.
import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = WeatherViewModel()

    @State private var city = ""
    @State private var selectedTab = 0
    @State private var selectedDayIndex = 0

    var body: some View {

        ZStack {

            // MARK: - Weather Tab

            if selectedTab == 0 {

                weatherBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 14) {

                        searchBar

                        if viewModel.isLoading &&
                            viewModel.weather == nil {

                            loadingView

                        } else if let weather = viewModel.weather {

                            cityHeader(weather)

                            if let forecast = viewModel.forecast {

                                SelectedWeatherCard(
                                    weather: weather,
                                    forecast: forecast,
                                    airQuality: viewModel.airQuality,
                                    selectedDayIndex: selectedDayIndex
                                )

                                HourlyForecastCard(
                                    forecast: forecast,
                                    selectedDayIndex: selectedDayIndex
                                )

                                WeeklyForecastCard(
                                    forecast: forecast,
                                    selectedDayIndex: $selectedDayIndex
                                )

                            } else {

                                CurrentWeatherCard(
                                    weather: weather,
                                    airQuality: viewModel.airQuality
                                )
                            }

                            WeatherDetailsCard(
                                weather: weather,
                                forecast: viewModel.forecast,
                                airQuality: viewModel.airQuality
                            )

                        } else if let errorMessage =
                                    viewModel.errorMessage {

                            errorView(errorMessage)

                        } else {

                            welcomeView
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }

            // MARK: - Locations Tab

            } else if selectedTab == 1 {

                SavedLocationsView { selectedCity in

                    city = selectedCity
                    selectedDayIndex = 0
                    selectedTab = 0

                    Task {

                        await viewModel.fetchWeather(
                            for: selectedCity
                        )
                    }
                }

            // MARK: - Map Tab

            } else if selectedTab == 2 {

                placeholderScreen(
                    icon: "map.fill",
                    title: "Weather Map",
                    message: "Interactive weather map coming soon."
                )

            // MARK: - Settings Tab

            } else {

                placeholderScreen(
                    icon: "gearshape.fill",
                    title: "Settings",
                    message: "SkyCast settings coming soon."
                )
            }

            // MARK: - Bottom Navigation

            VStack {

                Spacer()

                BottomWeatherTabBar(
                    selectedTab: $selectedTab
                )
            }
        }
        .task {

            await viewModel.fetchWeather(
                for: "Stockholm"
            )
        }
    }
}


// MARK: - Placeholder Screens

private extension ContentView {

    func placeholderScreen(
        icon: String,
        title: String,
        message: String
    ) -> some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color.blue,
                    Color.cyan,
                    Color.indigo.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {

                Image(systemName: icon)
                    .font(.system(size: 58))

                Text(title)
                    .font(.largeTitle.bold())

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(
                        .white.opacity(0.75)
                    )
            }
            .foregroundStyle(.white)
        }
    }
}


// MARK: - Search

private extension ContentView {

    var searchBar: some View {

        HStack(spacing: 12) {

            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.9))

            TextField(
                "Search city...",
                text: $city
            )
            .foregroundStyle(.white)
            .submitLabel(.search)
            .onSubmit {

                search()
            }

            if !city.isEmpty {

                Button {

                    city = ""

                } label: {

                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .foregroundStyle(
                        .white.opacity(0.75)
                    )
                }
            }

            Button {

                search()

            } label: {

                Image(
                    systemName: "arrow.right.circle.fill"
                )
                .font(.title2)
                .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
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
                .white.opacity(0.30),
                lineWidth: 1
            )
        )
    }

    func search() {

        let trimmedCity =
            city.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedCity.isEmpty else {
            return
        }

        selectedDayIndex = 0

        Task {

            await viewModel.fetchWeather(
                for: trimmedCity
            )
        }
    }
}


// MARK: - City Header

private extension ContentView {

    func cityHeader(
        _ weather: WeatherResponse
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 4
        ) {

            Text(weather.name)
                .font(
                    .system(
                        size: 38,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)

            Text(
                Date.now.formatted(
                    .dateTime
                        .weekday(.wide)
                        .month(.abbreviated)
                        .day()
                )
            )
            .font(.title3)
            .foregroundStyle(
                .white.opacity(0.85)
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 6)
    }
}


// MARK: - Background

private extension ContentView {

    var weatherBackground: some View {

        let condition =
            viewModel.weather?
                .weather
                .first?
                .main
                .lowercased()
            ?? ""

        return LinearGradient(
            colors: backgroundColors(
                for: condition
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func backgroundColors(
        for condition: String
    ) -> [Color] {

        let month =
            Calendar.current.component(
                .month,
                from: Date()
            )

        if condition.contains("snow") ||
            month == 12 ||
            month == 1 ||
            month == 2 {

            return [
                Color.blue.opacity(0.75),
                Color.cyan.opacity(0.55),
                Color.indigo.opacity(0.8)
            ]
        }

        if condition.contains("rain") ||
            condition.contains("drizzle") ||
            condition.contains("thunder") {

            return [
                Color.indigo,
                Color.blue.opacity(0.8),
                Color.gray
            ]
        }

        if condition.contains("cloud") {

            return [
                Color.blue.opacity(0.85),
                Color.cyan.opacity(0.65),
                Color.gray.opacity(0.7)
            ]
        }

        return [
            Color.blue,
            Color.cyan,
            Color.blue.opacity(0.75)
        ]
    }
}


// MARK: - Loading / Error

private extension ContentView {

    var loadingView: some View {

        VStack(spacing: 16) {

            ProgressView()
                .scaleEffect(1.3)
                .tint(.white)

            Text("Loading weather...")
                .foregroundStyle(.white)
        }
        .padding(.top, 100)
    }

    func errorView(
        _ message: String
    ) -> some View {

        VStack(spacing: 14) {

            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .font(.system(size: 40))

            Text(message)
                .font(.headline)
        }
        .foregroundStyle(.white)
        .padding(.top, 100)
    }

    var welcomeView: some View {

        VStack(spacing: 12) {

            Image(
                systemName:
                    "cloud.sun.fill"
            )
            .font(.system(size: 70))

            Text("SkyCast")
                .font(.largeTitle.bold())

            Text(
                "Search for a city to see the weather."
            )
            .foregroundStyle(
                .white.opacity(0.8)
            )
        }
        .foregroundStyle(.white)
        .padding(.top, 100)
    }
}


// MARK: - Current Weather Card

struct CurrentWeatherCard: View {

    let weather: WeatherResponse

    let airQuality: AirQualityResponse?

    var body: some View {

        HStack(spacing: 16) {

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text("Now")
                    .font(.headline)
                    .foregroundStyle(
                        .white.opacity(0.85)
                    )

                HStack(spacing: 10) {

                    Text(
                        "\(Int(weather.main.temp))°"
                    )
                    .font(
                        .system(
                            size: 64,
                            weight: .bold
                        )
                    )

                    Image(
                        systemName:
                            currentWeatherIcon
                    )
                    .font(
                        .system(size: 52)
                    )
                    .symbolRenderingMode(
                        .multicolor
                    )
                }

                Text(
                    weather
                        .weather
                        .first?
                        .description
                        .capitalized
                    ?? "Unknown"
                )
                .font(.title3)
            }

            Spacer()

            Divider()
                .background(
                    .white.opacity(0.35)
                )
                .frame(height: 105)

            VStack(
                alignment: .leading,
                spacing: 10
            ) {

                Text(
                    "Feels like \(Int(weather.main.feelsLike))°"
                )

                HStack(spacing: 14) {

                    Text(
                        "H: \(Int(weather.main.tempMax))°"
                    )

                    Text(
                        "L: \(Int(weather.main.tempMin))°"
                    )
                }

                if let aqi =
                    airQuality?
                        .current
                        .europeanAqi {

                    HStack(spacing: 6) {

                        Circle()
                            .fill(
                                airQualityColor(aqi)
                            )
                            .frame(
                                width: 9,
                                height: 9
                            )

                        Text(
                            airQualityText(aqi)
                        )
                        .font(.caption.bold())
                    }
                    .padding(
                        .horizontal,
                        10
                    )
                    .padding(
                        .vertical,
                        6
                    )
                    .background(
                        .white.opacity(0.12)
                    )
                    .clipShape(
                        Capsule()
                    )
                }
            }
            .font(.subheadline)
        }
        .foregroundStyle(.white)
        .padding(20)
        .glassCard()
    }

    private var currentWeatherIcon: String {

        let condition =
            weather
                .weather
                .first?
                .main
                .lowercased()
            ?? ""

        if condition.contains("clear") {

            return "sun.max.fill"
        }

        if condition.contains("cloud") {

            return "cloud.sun.fill"
        }

        if condition.contains("rain") ||
            condition.contains("drizzle") {

            return "cloud.rain.fill"
        }

        if condition.contains("snow") {

            return "cloud.snow.fill"
        }

        if condition.contains("thunder") {

            return "cloud.bolt.rain.fill"
        }

        if condition.contains("mist") ||
            condition.contains("fog") {

            return "cloud.fog.fill"
        }

        return "cloud.fill"
    }
}


// MARK: - Selected Day Weather Card

struct SelectedWeatherCard: View {

    let weather: WeatherResponse

    let forecast: ForecastResponse

    let airQuality: AirQualityResponse?

    let selectedDayIndex: Int

    var body: some View {

        if selectedDayIndex == 0 {

            CurrentWeatherCard(
                weather: weather,
                airQuality: airQuality
            )

        } else {

            forecastDayCard
        }
    }

    private var forecastDayCard: some View {

        HStack(spacing: 16) {

            VStack(
                alignment: .leading,
                spacing: 7
            ) {

                Text(
                    weekdayFull(
                        from: selectedDate
                    )
                )
                .font(.headline)
                .foregroundStyle(
                    .white.opacity(0.85)
                )

                HStack(spacing: 12) {

                    Text(
                        "\(Int(maxTemperature))°"
                    )
                    .font(
                        .system(
                            size: 60,
                            weight: .bold
                        )
                    )

                    Image(
                        systemName:
                            weatherIcon(
                                weatherCode
                            )
                    )
                    .font(
                        .system(size: 48)
                    )
                    .symbolRenderingMode(
                        .multicolor
                    )
                }

                Text(
                    weatherDescription(
                        weatherCode
                    )
                )
                .font(.title3)
            }

            Spacer()

            Divider()
                .background(
                    .white.opacity(0.35)
                )
                .frame(height: 110)

            VStack(
                alignment: .leading,
                spacing: 11
            ) {

                Text(
                    "High: \(Int(maxTemperature))°"
                )

                Text(
                    "Low: \(Int(minTemperature))°"
                )

                HStack(spacing: 6) {

                    Image(
                        systemName:
                            "drop.fill"
                    )

                    Text(
                        "\(precipitation)% rain"
                    )
                }
            }
            .font(.subheadline)
        }
        .foregroundStyle(.white)
        .padding(20)
        .glassCard()
    }

    private var selectedDate: String {

        guard
            selectedDayIndex
                < forecast.daily.time.count
        else {

            return ""
        }

        return forecast.daily.time[
            selectedDayIndex
        ]
    }

    private var weatherCode: Int {

        guard
            selectedDayIndex
                < forecast.daily.weatherCode.count
        else {

            return 0
        }

        return forecast.daily.weatherCode[
            selectedDayIndex
        ]
    }

    private var maxTemperature: Double {

        guard
            selectedDayIndex
                < forecast.daily.temperature2mMax.count
        else {

            return 0
        }

        return forecast.daily.temperature2mMax[
            selectedDayIndex
        ]
    }

    private var minTemperature: Double {

        guard
            selectedDayIndex
                < forecast.daily.temperature2mMin.count
        else {

            return 0
        }

        return forecast.daily.temperature2mMin[
            selectedDayIndex
        ]
    }

    private var precipitation: Int {

        guard
            selectedDayIndex
                < forecast.daily.precipitationProbabilityMax.count
        else {

            return 0
        }

        return forecast.daily.precipitationProbabilityMax[
            selectedDayIndex
        ]
    }
}


// MARK: - Hourly Forecast

struct HourlyForecastCard: View {

    let forecast: ForecastResponse

    let selectedDayIndex: Int

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                Text("Hourly Forecast")
                    .font(.headline)

                Spacer()

                Text(selectedDayName)
                    .font(.caption)
                    .foregroundStyle(
                        .white.opacity(0.75)
                    )
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 12) {

                    ForEach(
                        hourlyIndexes,
                        id: \.self
                    ) { index in

                        HourlyWeatherItem(
                            time:
                                displayHour(
                                    forecast.hourly.time[index]
                                ),
                            temperature:
                                forecast.hourly.temperature2m[index],
                            precipitation:
                                forecast.hourly.precipitationProbability[index],
                            weatherCode:
                                forecast.hourly.weatherCode[index]
                        )
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .padding(18)
        .glassCard()
    }

    private var selectedDate: String {

        guard
            selectedDayIndex
                < forecast.daily.time.count
        else {

            return ""
        }

        return forecast.daily.time[
            selectedDayIndex
        ]
    }

    private var selectedDayName: String {

        weekdayFull(
            from: selectedDate
        )
    }

    private var hourlyIndexes: [Int] {

        let matchingIndexes =
            forecast.hourly.time.indices.filter {

                forecast.hourly.time[$0]
                    .hasPrefix(selectedDate)
            }

        return Array(
            matchingIndexes.prefix(24)
        )
    }
}


struct HourlyWeatherItem: View {

    let time: String

    let temperature: Double

    let precipitation: Int

    let weatherCode: Int

    var body: some View {

        VStack(spacing: 8) {

            Text(time)
                .font(.caption)

            Image(
                systemName:
                    weatherIcon(
                        weatherCode
                    )
            )
            .font(.title2)
            .symbolRenderingMode(
                .multicolor
            )

            Text(
                "\(Int(temperature))°"
            )
            .font(.headline)

            HStack(spacing: 3) {

                Image(
                    systemName:
                        "drop.fill"
                )
                .font(.caption2)

                Text(
                    "\(precipitation)%"
                )
                .font(.caption2)
            }
            .foregroundStyle(
                .white.opacity(0.75)
            )
        }
        .frame(width: 60)
    }
}


// MARK: - Seven Day Forecast

struct WeeklyForecastCard: View {

    let forecast: ForecastResponse

    @Binding var selectedDayIndex: Int

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                Text("7-Day Forecast")
                    .font(.headline)

                Spacer()

                Text("Select a day")
                    .font(.caption)
                    .foregroundStyle(
                        .white.opacity(0.75)
                    )
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 10) {

                    ForEach(
                        dailyIndexes,
                        id: \.self
                    ) { index in

                        Button {

                            withAnimation(
                                .easeInOut(
                                    duration: 0.25
                                )
                            ) {

                                selectedDayIndex =
                                    index
                            }

                        } label: {

                            DailyForecastItem(
                                date:
                                    forecast.daily.time[index],
                                code:
                                    forecast.daily.weatherCode[index],
                                maxTemperature:
                                    forecast.daily.temperature2mMax[index],
                                minTemperature:
                                    forecast.daily.temperature2mMin[index],
                                selected:
                                    selectedDayIndex == index
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .padding(18)
        .glassCard()
    }

    private var dailyIndexes: [Int] {

        let count = min(
            7,
            forecast.daily.time.count,
            forecast.daily.weatherCode.count,
            forecast.daily.temperature2mMax.count,
            forecast.daily.temperature2mMin.count
        )

        return Array(0..<count)
    }
}


struct DailyForecastItem: View {

    let date: String

    let code: Int

    let maxTemperature: Double

    let minTemperature: Double

    let selected: Bool

    var body: some View {

        VStack(spacing: 9) {

            Text(
                weekday(from: date)
            )
            .font(.headline)

            Image(
                systemName:
                    weatherIcon(code)
            )
            .font(.title)
            .symbolRenderingMode(
                .multicolor
            )

            Text(
                "\(Int(maxTemperature))°"
            )
            .font(.headline)

            Text(
                "\(Int(minTemperature))°"
            )
            .foregroundStyle(
                .white.opacity(0.7)
            )
        }
        .frame(
            width: 72,
            height: 125
        )
        .background(
            .white.opacity(
                selected
                    ? 0.18
                    : 0.08
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
        .overlay {

            if selected {

                RoundedRectangle(
                    cornerRadius: 20
                )
                .stroke(
                    .white,
                    lineWidth: 2
                )
            }
        }
    }
}


// MARK: - Weather Details

struct WeatherDetailsCard: View {

    let weather: WeatherResponse

    let forecast: ForecastResponse?

    let airQuality: AirQualityResponse?

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            Text("Weather Details")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {

                WeatherMetricCard(
                    icon:
                        "drop.fill",
                    title:
                        "Precipitation",
                    value:
                        "\(currentPrecipitation)%"
                )

                WeatherMetricCard(
                    icon:
                        "wind",
                    title:
                        "Wind",
                    value:
                        "\(Int(weather.wind.speed)) m/s"
                )

                WeatherMetricCard(
                    icon:
                        "humidity.fill",
                    title:
                        "Humidity",
                    value:
                        "\(weather.main.humidity)%"
                )

                WeatherMetricCard(
                    icon:
                        "leaf.fill",
                    title:
                        "Air quality",
                    value:
                        airQualityLabel
                )
            }
        }
        .padding(18)
        .glassCard()
    }

    private var currentPrecipitation: Int {

        forecast?
            .hourly
            .precipitationProbability
            .first
        ?? 0
    }

    private var airQualityLabel: String {

        guard let aqi =
            airQuality?
                .current
                .europeanAqi
        else {

            return "--"
        }

        return airQualityText(aqi)
    }
}


struct WeatherMetricCard: View {

    let icon: String

    let title: String

    let value: String

    var body: some View {

        HStack(spacing: 12) {

            Image(systemName: icon)
                .font(.title2)
                .frame(
                    width: 38,
                    height: 38
                )

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(.caption)
                    .foregroundStyle(
                        .white.opacity(0.75)
                    )

                Text(value)
                    .font(.headline)
            }

            Spacer()
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(
            .white.opacity(0.10)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
}


// MARK: - Bottom Navigation

struct BottomWeatherTabBar: View {

    @Binding var selectedTab: Int

    private let tabs = [

        ("cloud.fill", "Weather"),

        ("location.fill", "Locations"),

        ("map.fill", "Map"),

        ("gearshape.fill", "Settings")
    ]

    var body: some View {

        HStack {

            ForEach(
                tabs.indices,
                id: \.self
            ) { index in

                Button {

                    selectedTab = index

                } label: {

                    VStack(spacing: 5) {

                        Image(
                            systemName:
                                tabs[index].0
                        )
                        .font(.title3)

                        Text(
                            tabs[index].1
                        )
                        .font(.caption2)
                    }
                    .foregroundStyle(
                        selectedTab == index
                            ? .white
                            : .white.opacity(0.65)
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(
                        .vertical,
                        10
                    )
                    .background {

                        if selectedTab == index {

                            RoundedRectangle(
                                cornerRadius: 18
                            )
                            .fill(
                                .white.opacity(0.15)
                            )
                        }
                    }
                }
            }
        }
        .padding(8)
        .background(
            .ultraThinMaterial
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 28
            )
            .stroke(
                .white.opacity(0.25),
                lineWidth: 1
            )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}


// MARK: - Glass Modifier

extension View {

    func glassCard() -> some View {

        self
            .background(
                .ultraThinMaterial
            )
            .background(
                .white.opacity(0.06)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 28
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: 28
                )
                .stroke(
                    .white.opacity(0.25),
                    lineWidth: 1
                )
            )
            .shadow(
                color:
                    .black.opacity(0.10),
                radius: 15,
                x: 0,
                y: 8
            )
    }
}


// MARK: - Weather Helpers

func weatherIcon(
    _ code: Int
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

    case 51...57:

        return "cloud.drizzle.fill"

    case 61...67:

        return "cloud.rain.fill"

    case 71...77:

        return "cloud.snow.fill"

    case 80...82:

        return "cloud.heavyrain.fill"

    case 85, 86:

        return "cloud.snow.fill"

    case 95...99:

        return "cloud.bolt.rain.fill"

    default:

        return "cloud.fill"
    }
}


func displayHour(
    _ rawDate: String
) -> String {

    let formatter =
        DateFormatter()

    formatter.dateFormat =
        "yyyy-MM-dd'T'HH:mm"

    guard let date =
        formatter.date(
            from: rawDate
        )
    else {

        return rawDate
    }

    formatter.dateFormat =
        "HH:mm"

    return formatter.string(
        from: date
    )
}


func weekday(
    from rawDate: String
) -> String {

    let formatter =
        DateFormatter()

    formatter.dateFormat =
        "yyyy-MM-dd"

    guard let date =
        formatter.date(
            from: rawDate
        )
    else {

        return rawDate
    }

    formatter.dateFormat =
        "EEE"

    return formatter.string(
        from: date
    )
}


func weekdayFull(
    from rawDate: String
) -> String {

    let formatter =
        DateFormatter()

    formatter.dateFormat =
        "yyyy-MM-dd"

    guard let date =
        formatter.date(
            from: rawDate
        )
    else {

        return rawDate
    }

    formatter.dateFormat =
        "EEEE"

    return formatter.string(
        from: date
    )
}


func weatherDescription(
    _ code: Int
) -> String {

    switch code {

    case 0:

        return "Clear Sky"

    case 1:

        return "Mostly Clear"

    case 2:

        return "Partly Cloudy"

    case 3:

        return "Overcast"

    case 45, 48:

        return "Fog"

    case 51...57:

        return "Drizzle"

    case 61...67:

        return "Rain"

    case 71...77:

        return "Snow"

    case 80...82:

        return "Rain Showers"

    case 85, 86:

        return "Snow Showers"

    case 95...99:

        return "Thunderstorm"

    default:

        return "Unknown"
    }
}


func airQualityText(
    _ aqi: Int
) -> String {

    switch aqi {

    case 0...20:

        return "Good"

    case 21...40:

        return "Fair"

    case 41...60:

        return "Moderate"

    case 61...80:

        return "Poor"

    case 81...100:

        return "Very Poor"

    default:

        return "Extremely Poor"
    }
}


func airQualityColor(
    _ aqi: Int
) -> Color {

    switch aqi {

    case 0...20:

        return .green

    case 21...40:

        return .mint

    case 41...60:

        return .yellow

    case 61...80:

        return .orange

    default:

        return .red
    }
}


#Preview {

    ContentView()
}
