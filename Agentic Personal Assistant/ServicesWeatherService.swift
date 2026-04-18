//
//  WeatherService.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation
import CoreLocation
import Combine

enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError
    case missingAPIKey
    case locationNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather API URL"
        case .invalidResponse:
            return "Invalid response from weather service"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to decode weather data"
        case .missingAPIKey:
            return "Weather API key is missing"
        case .locationNotFound:
            return "Location not found"
        }
    }
}

@MainActor
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    // TODO: Get your free API key from https://openweathermap.org/api
    private var apiKey: String {
        return Configuration.weatherAPIKey
    }
    
    private init() {}
    
    func fetchWeather(for city: String) async throws -> FormattedWeather {
        guard !apiKey.isEmpty else {
            throw WeatherError.missingAPIKey
        }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric") // Celsius
        ]
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw WeatherError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            
            return formatWeather(weatherResponse)
            
        } catch is DecodingError {
            throw WeatherError.decodingError
        } catch {
            throw WeatherError.networkError(error)
        }
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> FormattedWeather {
        guard !apiKey.isEmpty else {
            throw WeatherError.missingAPIKey
        }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw WeatherError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            
            return formatWeather(weatherResponse)
            
        } catch is DecodingError {
            throw WeatherError.decodingError
        } catch {
            throw WeatherError.networkError(error)
        }
    }
    
    private func formatWeather(_ response: WeatherResponse) -> FormattedWeather {
        let mainCondition = response.weather.first
        
        return FormattedWeather(
            location: response.name,
            temperature: response.main.temp,
            feelsLike: response.main.feelsLike,
            condition: mainCondition?.main ?? "Unknown",
            description: mainCondition?.description.capitalized ?? "No description",
            humidity: response.main.humidity,
            windSpeed: response.wind?.speed ?? 0.0
        )
    }
}
