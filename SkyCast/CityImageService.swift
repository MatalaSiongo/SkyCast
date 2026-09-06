//
//  CityImageService.swift
//  SkyCast
//
//  Created by Matala on 2026-09-06.
//

import Foundation

struct CityImage: Equatable {
    let imageURL: URL
    let photographerName: String
    let photographerURL: URL?
    let pexelsURL: URL?
}

enum CityImageServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case badServerResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "The Pexels API key is missing."
        case .invalidURL:
            return "Could not create the Pexels request URL."
        case .badServerResponse:
            return "Pexels returned an unexpected response."
        }
    }
}

actor CityImageService {

    private var cache: [String: CityImage] = [:]

    private var apiKey: String {
        Bundle.main.object(
            forInfoDictionaryKey: "PEXELS_API_KEY"
        ) as? String ?? ""
    }

    func fetchCityImage(for city: String) async throws -> CityImage? {

        let normalizedCity = city
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedCity.isEmpty else {
            return nil
        }

        // Return the image we've already found during this app session.
        if let cachedImage = cache[normalizedCity] {
            return cachedImage
        }

        guard !apiKey.isEmpty else {
            throw CityImageServiceError.missingAPIKey
        }

        var components = URLComponents(
            string: "https://api.pexels.com/v1/search"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "query",
                value: "\(city) city landmark"
            ),
            URLQueryItem(
                name: "orientation",
                value: "portrait"
            ),
            URLQueryItem(
                name: "per_page",
                value: "10"
            )
        ]

        guard let url = components?.url else {
            throw CityImageServiceError.invalidURL
        }

        var request = URLRequest(url: url)

        request.setValue(
            apiKey,
            forHTTPHeaderField: "Authorization"
        )

        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CityImageServiceError.badServerResponse
        }

        let decodedResponse = try JSONDecoder().decode(
            PexelsSearchResponse.self,
            from: data
        )

        guard let photo = decodedResponse.photos.first,
              let imageURL = URL(string: photo.src.portrait) else {
            return nil
        }

        let cityImage = CityImage(
            imageURL: imageURL,
            photographerName: photo.photographer,
            photographerURL: URL(string: photo.photographerURL),
            pexelsURL: URL(string: photo.url)
        )

        cache[normalizedCity] = cityImage

        return cityImage
    }
}


// MARK: - Pexels API Models

private struct PexelsSearchResponse: Decodable {
    let photos: [PexelsPhoto]
}

private struct PexelsPhoto: Decodable {
    let id: Int
    let url: String
    let photographer: String
    let photographerURL: String
    let src: PexelsPhotoSource

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case photographer
        case photographerURL = "photographer_url"
        case src
    }
}

private struct PexelsPhotoSource: Decodable {
    let portrait: String
}
