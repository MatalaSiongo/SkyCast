//
//  SettingsView.swift
//  SkyCast
//
//  Created by Matala on 2026-09-05.
import SwiftUI
import UserNotifications

struct SettingsView: View {

    // MARK: - Persistent Settings

    @AppStorage("temperatureUnit")
    private var temperatureUnit = TemperatureUnit.celsius.rawValue

    @AppStorage("windSpeedUnit")
    private var windSpeedUnit = WindSpeedUnit.metersPerSecond.rawValue

    @AppStorage("skycastAppearance")
    private var appearance = AppAppearance.system.rawValue

    @AppStorage("weatherNotifications")
    private var weatherNotifications = false

    @AppStorage("weatherNotificationHour")
    private var weatherNotificationHour = 8

    @AppStorage("weatherNotificationMinute")
    private var weatherNotificationMinute = 0

    @AppStorage("showPrecipitation")
    private var showPrecipitation = true

    @AppStorage("showAirQuality")
    private var showAirQuality = true

    @StateObject private var notificationManager =
        NotificationManager.shared

    @State private var showingResetConfirmation = false
    @State private var showingAbout = false
    @State private var showingNotificationAlert = false

    @State private var notificationAlertTitle = ""
    @State private var notificationAlertMessage = ""

    var body: some View {
        ZStack {
            background

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    unitsSection
                    appearanceSection
                    weatherSection
                    aboutSection
                    resetSection

                    Spacer(minLength: 110)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .task {
            await notificationManager
                .refreshAuthorizationStatus()

            await syncNotificationPreference()
        }
        .confirmationDialog(
            "Reset SkyCast Settings?",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Reset Settings",
                role: .destructive
            ) {
                resetSettings()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                "Your SkyCast preferences will return to their default values."
            )
        }
        .sheet(
            isPresented: $showingAbout
        ) {
            aboutSheet
        }
        .alert(
            notificationAlertTitle,
            isPresented: $showingNotificationAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(notificationAlertMessage)
        }
    }

    // MARK: - Background

    private var background: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.75),
                Color.cyan.opacity(0.45),
                Color.indigo.opacity(0.55)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text("Settings")
                    .font(
                        .system(
                            size: 32,
                            weight: .bold
                        )
                    )

                Text(
                    "Customize your SkyCast experience"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Image(
                systemName: "gearshape.fill"
            )
            .font(.system(size: 30))
            .symbolRenderingMode(.hierarchical)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Units

    private var unitsSection: some View {
        SettingsGlassCard(
            title: "Units",
            icon: "thermometer.medium"
        ) {
            VStack(spacing: 16) {

                settingsPickerRow(
                    title: "Temperature",
                    icon: "thermometer"
                ) {
                    Picker(
                        "Temperature",
                        selection: $temperatureUnit
                    ) {
                        ForEach(
                            TemperatureUnit.allCases
                        ) { unit in
                            Text(unit.title)
                                .tag(unit.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                settingsPickerRow(
                    title: "Wind Speed",
                    icon: "wind"
                ) {
                    Picker(
                        "Wind Speed",
                        selection: $windSpeedUnit
                    ) {
                        ForEach(
                            WindSpeedUnit.allCases
                        ) { unit in
                            Text(unit.title)
                                .tag(unit.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        SettingsGlassCard(
            title: "Appearance",
            icon: "paintbrush.fill"
        ) {
            VStack(spacing: 14) {

                Picker(
                    "Appearance",
                    selection: $appearance
                ) {
                    ForEach(
                        AppAppearance.allCases
                    ) { option in
                        Label(
                            option.title,
                            systemImage: option.icon
                        )
                        .tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                HStack(spacing: 8) {

                    Image(
                        systemName: appearanceIcon
                    )
                    .foregroundStyle(.secondary)

                    Text(
                        "Your preference is saved automatically."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Spacer()
                }
            }
        }
    }

    // MARK: - Weather Preferences

    private var weatherSection: some View {
        SettingsGlassCard(
            title: "Weather",
            icon: "cloud.sun.fill"
        ) {
            VStack(spacing: 0) {

                notificationSection

                Divider()
                    .padding(.vertical, 10)

                SettingsToggleRow(
                    title: "Precipitation",
                    subtitle:
                        "Show rain and snow information",
                    icon: "drop.fill",
                    isOn: $showPrecipitation
                )

                Divider()
                    .padding(.vertical, 10)

                SettingsToggleRow(
                    title: "Air Quality",
                    subtitle:
                        "Show air-quality information",
                    icon: "aqi.medium",
                    isOn: $showAirQuality
                )
            }
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        VStack(spacing: 12) {

            HStack(spacing: 14) {

                Image(
                    systemName: "bell.fill"
                )
                .font(.title3)
                .frame(width: 28)

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(
                        "Weather Notifications"
                    )
                    .font(.body.weight(.medium))

                    Text(
                        notificationStatusText
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle(
                    "",
                    isOn: Binding(
                        get: {
                            weatherNotifications
                        },
                        set: { newValue in
                            Task {
                                await handleNotificationToggle(
                                    newValue
                                )
                            }
                        }
                    )
                )
                .labelsHidden()
                .disabled(
                    notificationManager
                        .authorizationStatus
                        == .denied
                )
            }

            if weatherNotifications {

                Divider()

                HStack {

                    Label(
                        "Daily Reminder",
                        systemImage: "clock.fill"
                    )
                    .font(
                        .body.weight(.medium)
                    )

                    Spacer()

                    DatePicker(
                        "",
                        selection:
                            notificationTimeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .onChange(
                        of: notificationTimeBinding.wrappedValue
                    ) { _, _ in
                        Task {
                            await rescheduleReminder()
                        }
                    }
                }

                Divider()

                Button {
                    Task {
                        await sendTestNotification()
                    }
                } label: {

                    HStack {

                        Label(
                            "Send Test Notification",
                            systemImage:
                                "paperplane.fill"
                        )

                        Spacer()

                        Image(
                            systemName:
                                "chevron.right"
                        )
                        .font(.caption)
                    }
                    .fontWeight(.semibold)
                }
                .buttonStyle(.plain)
            }

            if notificationManager
                .authorizationStatus == .denied {

                Divider()

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    Image(
                        systemName:
                            "exclamationmark.triangle.fill"
                    )

                    Text(
                        "Notifications are blocked in iOS Settings. Allow notifications for SkyCast to use weather reminders."
                    )
                    .font(.caption)

                    Spacer()
                }
                .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        SettingsGlassCard(
            title: "About",
            icon: "info.circle.fill"
        ) {
            Button {
                showingAbout = true
            } label: {

                HStack(spacing: 14) {

                    Image(
                        systemName:
                            "cloud.sun.fill"
                    )
                    .font(.title2)
                    .frame(width: 32)

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text("About SkyCast")
                            .font(
                                .body.weight(.semibold)
                            )

                        Text(
                            "Version, weather data and app information"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .font(
                        .caption.weight(.bold)
                    )
                    .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Reset

    private var resetSection: some View {
        Button {
            showingResetConfirmation = true
        } label: {

            HStack {

                Image(
                    systemName:
                        "arrow.counterclockwise"
                )

                Text("Reset Settings")
                    .fontWeight(.semibold)

                Spacer()

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(.caption)
            }
            .foregroundStyle(.red)
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 22
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 22
                )
                .stroke(
                    .white.opacity(0.3),
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - About Sheet

    private var aboutSheet: some View {
        NavigationStack {
            ZStack {

                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.75),
                        Color.cyan.opacity(0.4),
                        Color.indigo.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {

                        Image(
                            systemName:
                                "cloud.sun.fill"
                        )
                        .font(.system(size: 72))
                        .symbolRenderingMode(
                            .hierarchical
                        )

                        VStack(spacing: 6) {

                            Text("SkyCast")
                                .font(
                                    .largeTitle.bold()
                                )

                            Text(
                                "Weather made simple."
                            )
                            .foregroundStyle(
                                .secondary
                            )
                        }

                        SettingsGlassCard(
                            title: "App Information",
                            icon: "iphone"
                        ) {
                            VStack(spacing: 14) {

                                informationRow(
                                    title: "Version",
                                    value: appVersion
                                )

                                Divider()

                                informationRow(
                                    title: "Build",
                                    value: buildNumber
                                )
                            }
                        }

                        SettingsGlassCard(
                            title: "Weather Data",
                            icon: "cloud.fill"
                        ) {
                            VStack(
                                alignment: .leading,
                                spacing: 10
                            ) {

                                Text(
                                    "SkyCast uses weather services to provide current conditions, forecasts and air-quality information."
                                )
                                .font(.subheadline)

                                Text(
                                    "Forecast data powered in part by Open-Meteo. Air-quality data is provided through Open-Meteo using CAMS data."
                                )
                                .font(.caption)
                                .foregroundStyle(
                                    .secondary
                                )
                            }
                            .frame(
                                maxWidth:
                                    .infinity,
                                alignment:
                                    .leading
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(
                .inline
            )
            .toolbar {

                ToolbarItem(
                    placement:
                        .topBarTrailing
                ) {
                    Button("Done") {
                        showingAbout = false
                    }
                }
            }
        }
    }

    // MARK: - Notification Logic

    private func handleNotificationToggle(
        _ enabled: Bool
    ) async {

        if enabled {

            let status =
                notificationManager
                    .authorizationStatus

            switch status {

            case .notDetermined:

                let granted =
                    await notificationManager
                        .requestPermission()

                if granted {

                    weatherNotifications = true

                    await scheduleReminder()

                } else {

                    weatherNotifications = false

                    showNotificationMessage(
                        title:
                            "Notifications Not Enabled",
                        message:
                            "SkyCast does not have permission to send notifications."
                    )
                }

            case .authorized,
                 .provisional,
                 .ephemeral:

                weatherNotifications = true

                await scheduleReminder()

            case .denied:

                weatherNotifications = false

                showNotificationMessage(
                    title:
                        "Notifications Are Blocked",
                    message:
                        "Open iOS Settings and allow notifications for SkyCast."
                )

            @unknown default:

                weatherNotifications = false
            }

        } else {

            weatherNotifications = false

            notificationManager
                .cancelDailyReminder()
        }
    }

    private func scheduleReminder() async {

        do {
            try await notificationManager
                .scheduleDailyReminder(
                    hour:
                        weatherNotificationHour,
                    minute:
                        weatherNotificationMinute
                )

        } catch {

            weatherNotifications = false

            showNotificationMessage(
                title:
                    "Unable to Schedule Reminder",
                message:
                    error.localizedDescription
            )
        }
    }

    private func rescheduleReminder() async {

        guard weatherNotifications else {
            return
        }

        await scheduleReminder()
    }

    private func sendTestNotification() async {

        do {

            try await notificationManager
                .scheduleTestNotification()

            showNotificationMessage(
                title:
                    "Test Notification Scheduled",
                message:
                    "SkyCast will send a test notification in about 5 seconds."
            )

        } catch {

            showNotificationMessage(
                title:
                    "Unable to Send Test",
                message:
                    error.localizedDescription
            )
        }
    }

    private func syncNotificationPreference() async {

        let status =
            notificationManager
                .authorizationStatus

        if status == .denied {

            weatherNotifications = false

            notificationManager
                .cancelDailyReminder()

            return
        }

        if weatherNotifications {

            let exists =
                await notificationManager
                    .hasScheduledDailyReminder()

            if !exists &&
                (
                    status == .authorized ||
                    status == .provisional ||
                    status == .ephemeral
                ) {

                await scheduleReminder()
            }
        }
    }

    // MARK: - Notification Helpers

    private var notificationStatusText: String {

        switch notificationManager
            .authorizationStatus {

        case .notDetermined:

            return weatherNotifications
                ? "Notification permission pending"
                : "Daily weather reminders"

        case .denied:

            return "Blocked in iOS Settings"

        case .authorized:

            return weatherNotifications
                ? "Daily reminder enabled"
                : "Notifications allowed"

        case .provisional:

            return weatherNotifications
                ? "Daily reminder enabled"
                : "Notifications allowed quietly"

        case .ephemeral:

            return "Temporary notification permission"

        @unknown default:

            return "Notification status unavailable"
        }
    }

    private var notificationTimeBinding:
        Binding<Date> {

        Binding(
            get: {

                var components =
                    DateComponents()

                components.hour =
                    weatherNotificationHour

                components.minute =
                    weatherNotificationMinute

                return Calendar.current.date(
                    from: components
                ) ?? Date()

            },
            set: { newDate in

                let components =
                    Calendar.current.dateComponents(
                        [.hour, .minute],
                        from: newDate
                    )

                weatherNotificationHour =
                    components.hour ?? 8

                weatherNotificationMinute =
                    components.minute ?? 0
            }
        )
    }

    private func showNotificationMessage(
        title: String,
        message: String
    ) {

        notificationAlertTitle = title
        notificationAlertMessage = message
        showingNotificationAlert = true
    }

    // MARK: - General Helpers

    private func settingsPickerRow<
        Content: View
    >(
        title: String,
        icon: String,
        @ViewBuilder
        content: () -> Content
    ) -> some View {

        HStack {

            Label(
                title,
                systemImage: icon
            )
            .font(.body.weight(.medium))

            Spacer()

            content()
        }
    }

    private func informationRow(
        title: String,
        value: String
    ) -> some View {

        HStack {

            Text(title)
                .foregroundStyle(
                    .secondary
                )

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }

    private var appearanceIcon: String {

        switch AppAppearance(
            rawValue: appearance
        ) ?? .system {

        case .system:
            return "circle.lefthalf.filled"

        case .light:
            return "sun.max.fill"

        case .dark:
            return "moon.fill"
        }
    }

    private var appVersion: String {

        Bundle.main.object(
            forInfoDictionaryKey:
                "CFBundleShortVersionString"
        ) as? String ?? "1.0"
    }

    private var buildNumber: String {

        Bundle.main.object(
            forInfoDictionaryKey:
                "CFBundleVersion"
        ) as? String ?? "1"
    }

    private func resetSettings() {

        temperatureUnit =
            TemperatureUnit.celsius.rawValue

        windSpeedUnit =
            WindSpeedUnit
                .metersPerSecond
                .rawValue

        appearance =
            AppAppearance.system.rawValue

        weatherNotifications = false

        weatherNotificationHour = 8
        weatherNotificationMinute = 0

        showPrecipitation = true
        showAirQuality = true

        notificationManager
            .cancelDailyReminder()
    }
}

// MARK: - Settings Card

private struct SettingsGlassCard<
    Content: View
>: View {

    let title: String
    let icon: String
    let content: Content

    init(
        title: String,
        icon: String,
        @ViewBuilder
        content: () -> Content
    ) {

        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            Label(
                title,
                systemImage: icon
            )
            .font(.headline)

            content
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            .ultraThinMaterial
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 24
            )
            .stroke(
                .white.opacity(0.3),
                lineWidth: 1
            )
        }
        .shadow(radius: 8)
    }
}

// MARK: - Toggle Row

private struct SettingsToggleRow: View {

    let title: String
    let subtitle: String
    let icon: String

    @Binding var isOn: Bool

    var body: some View {

        HStack(spacing: 14) {

            Image(
                systemName: icon
            )
            .font(.title3)
            .frame(width: 28)

            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(title)
                    .font(
                        .body.weight(.medium)
                    )

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
            }

            Spacer()

            Toggle(
                "",
                isOn: $isOn
            )
            .labelsHidden()
        }
    }
}

// MARK: - Temperature Unit

enum TemperatureUnit:
    String,
    CaseIterable,
    Identifiable {

    case celsius
    case fahrenheit

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .celsius:
            return "Celsius (°C)"

        case .fahrenheit:
            return "Fahrenheit (°F)"
        }
    }
}

// MARK: - Wind Unit

enum WindSpeedUnit:
    String,
    CaseIterable,
    Identifiable {

    case metersPerSecond
    case kilometersPerHour
    case milesPerHour

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .metersPerSecond:
            return "m/s"

        case .kilometersPerHour:
            return "km/h"

        case .milesPerHour:
            return "mph"
        }
    }
}

// MARK: - Appearance

enum AppAppearance:
    String,
    CaseIterable,
    Identifiable {

    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .system:
            return "System"

        case .light:
            return "Light"

        case .dark:
            return "Dark"
        }
    }

    var icon: String {

        switch self {

        case .system:
            return "circle.lefthalf.filled"

        case .light:
            return "sun.max.fill"

        case .dark:
            return "moon.fill"
        }
    }
}
