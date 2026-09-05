//
//  ContentView.swift
//  SkyCast
//
//  Created by Matala on 2026-08-19.
//
import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = WeatherViewModel()
    @State private var city = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                 
                HStack {
                    TextField("Search city...", text: $city)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                await viewModel.fetchWeather(for: city)
                            }
                        }

                    Button {
                        Task {
                            await viewModel.fetchWeather(for: city)
                        }
                    } label: {
                        // We'll connect the API here next
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal)
                if let weather = viewModel.weather {

                    Text(weather.name)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 90))
                        .foregroundStyle(.white)

                    Text("\(Int(weather.main.temp))°")
                        .font(.system(size: 72, weight: .thin))
                        .foregroundStyle(.white)

                    Text(weather.weather.first?.description.capitalized ?? "Unknown")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))

                    HStack(spacing: 40) {

                        WeatherInfoView(
                            icon: "drop.fill",
                            title: "Humidity",
                            value: "\(weather.main.humidity)%"
                        )

                        WeatherInfoView(
                            icon: "wind",
                            title: "Wind",
                            value: "\(Int(weather.wind.speed)) m/s"
                        )
                    }
                    .padding(.top, 20)

                } else if viewModel.isLoading {

                    ProgressView()
                        .tint(.white)

                    Text("Loading weather...")
                        .foregroundStyle(.white)

                } else if let errorMessage = viewModel.errorMessage {

                    Text(errorMessage)
                        .foregroundStyle(.white)

                } else {

                    Text("SkyCast")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Spacer()
            }
            .padding(.top, 80)
        }
        .task {
            await viewModel.fetchWeather(for: "Stockholm")
        }
    }
}

struct WeatherInfoView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)

            Text(title)
                .font(.caption)

            Text(value)
                .font(.headline)
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    ContentView()
}
