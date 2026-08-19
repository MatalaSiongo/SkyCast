//
//  ContentView.swift
//  SkyCast
//
//  Created by Matala on 2026-08-19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                Text("Stockholm")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.white)

                Text("18°")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(.white)

                Text("Partly Cloudy")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))

                HStack(spacing: 40) {

                    WeatherInfoView(
                        icon: "drop.fill",
                        title: "Humidity",
                        value: "72%"
                    )

                    WeatherInfoView(
                        icon: "wind",
                        title: "Wind",
                        value: "12 km/h"
                    )
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding(.top, 80)
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
