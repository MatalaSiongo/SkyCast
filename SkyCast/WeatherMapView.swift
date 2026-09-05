//
//  WeatherMapView.swift
//  SkyCast
//
//  Created by Matala on 2026-09-05.
import SwiftUI
import MapKit

struct WeatherMapView: View {
    let cityName: String
    let temperature: Double
    let condition: String
    let latitude: Double
    let longitude: Double
    let onShowWeather: () -> Void

    @State private var position: MapCameraPosition
    @State private var mapStyle: SkyCastMapStyle = .standard

    init(
        cityName: String,
        temperature: Double,
        condition: String,
        latitude: Double,
        longitude: Double,
        onShowWeather: @escaping () -> Void
    ) {
        self.cityName = cityName
        self.temperature = temperature
        self.condition = condition
        self.latitude = latitude
        self.longitude = longitude
        self.onShowWeather = onShowWeather

        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        _position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.18,
                        longitudeDelta: 0.18
                    )
                )
            )
        )
    }

    var body: some View {
        ZStack {
            map

            VStack(spacing: 0) {
                header

                Spacer()

                VStack(spacing: 12) {
                    mapControls
                    weatherCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 105)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Map

    @ViewBuilder
    private var map: some View {
        Map(position: $position) {
            Annotation(
                cityName,
                coordinate: cityCoordinate,
                anchor: .bottom
            ) {
                cityMarker
            }
        }
        .mapStyle(selectedMapStyle)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Weather Map")
                    .font(.system(size: 28, weight: .bold))

                Text(cityName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: weatherSymbol)
                .font(.system(size: 28))
                .symbolRenderingMode(.hierarchical)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
    }

    // MARK: - Marker

    private var cityMarker: some View {
        VStack(spacing: 3) {
            HStack(spacing: 6) {
                Image(systemName: weatherSymbol)

                Text("\(Int(temperature.rounded()))°")
                    .fontWeight(.bold)
            }
            .font(.system(size: 16))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.4), lineWidth: 1)
            }
            .shadow(radius: 6)

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 28))
                .symbolRenderingMode(.hierarchical)
        }
    }

    // MARK: - Controls

    private var mapControls: some View {
        HStack(spacing: 10) {
            Button {
                recenterMap()
            } label: {
                Label("Recenter", systemImage: "scope")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(GlassMapButtonStyle())

            Menu {
                ForEach(SkyCastMapStyle.allCases) { style in
                    Button {
                        mapStyle = style
                    } label: {
                        if mapStyle == style {
                            Label(style.title, systemImage: "checkmark")
                        } else {
                            Text(style.title)
                        }
                    }
                }
            } label: {
                Label(mapStyle.title, systemImage: "square.3.layers.3d")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(GlassMapButtonStyle())
        }
    }

    // MARK: - Weather Card

    private var weatherCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(cityName)
                        .font(.title2.bold())

                    Text(condition.capitalized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 10) {
                    Image(systemName: weatherSymbol)
                        .font(.system(size: 28))

                    Text("\(Int(temperature.rounded()))°")
                        .font(.system(size: 36, weight: .semibold))
                }
            }

            Divider()

            Button {
                onShowWeather()
            } label: {
                HStack {
                    Image(systemName: "cloud.sun.fill")

                    Text("View full weather")
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        }
        .shadow(radius: 12)
    }

    // MARK: - Helpers

    private var cityCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    private func recenterMap() {
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .region(
                MKCoordinateRegion(
                    center: cityCoordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.18,
                        longitudeDelta: 0.18
                    )
                )
            )
        }
    }

    private var selectedMapStyle: MapStyle {
        switch mapStyle {
        case .standard:
            return .standard

        case .hybrid:
            return .hybrid

        case .imagery:
            return .imagery
        }
    }

    private var weatherSymbol: String {
        let value = condition.lowercased()

        if value.contains("thunder") {
            return "cloud.bolt.rain.fill"
        }

        if value.contains("snow") {
            return "cloud.snow.fill"
        }

        if value.contains("rain") || value.contains("drizzle") {
            return "cloud.rain.fill"
        }

        if value.contains("cloud") {
            return "cloud.fill"
        }

        if value.contains("mist") ||
            value.contains("fog") ||
            value.contains("haze") {
            return "cloud.fog.fill"
        }

        if value.contains("clear") {
            return "sun.max.fill"
        }

        return "cloud.sun.fill"
    }
}

// MARK: - Map Style

private enum SkyCastMapStyle: String, CaseIterable, Identifiable {
    case standard
    case hybrid
    case imagery

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .standard:
            return "Standard"
        case .hybrid:
            return "Hybrid"
        case .imagery:
            return "Satellite"
        }
    }
}

// MARK: - Glass Button Style

private struct GlassMapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        .white.opacity(configuration.isPressed ? 0.55 : 0.3),
                        lineWidth: 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(
                .easeOut(duration: 0.15),
                value: configuration.isPressed
            )
    }
}
