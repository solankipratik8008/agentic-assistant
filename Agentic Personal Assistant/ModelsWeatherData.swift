//
//  WeatherData.swift
//  Agentic Personal Assistant
//
//  Created by Pratik Solanki on 2026-04-17.
//

import Foundation

// MARK: - Weather API Response Models
/// Response from OpenWeatherMap API
struct WeatherResponse: Codable {
    let coord: Coordinates?
    let weather: [Weather]
    let base: String?
    let main: MainWeather
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let dt: Int
    let sys: Sys?
    let timezone: Int?
    let id: Int
    let name: String
    let cod: Int
}

struct Coordinates: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int?
    let gust: Double?
}

struct Clouds: Codable {
    let all: Int
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

// MARK: - Formatted Weather for Display
/// User-friendly weather data for displaying in chat
struct FormattedWeather {
    let location: String
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let description: String
    let humidity: Int
    let windSpeed: Double
    
    var temperatureCelsius: String {
        String(format: "%.1f°C", temperature)
    }
    
    var temperatureFahrenheit: String {
        let fahrenheit = (temperature * 9/5) + 32
        return String(format: "%.1f°F", fahrenheit)
    }
    
    var summary: String {
        """
        🌤️ Weather for \(location):
        
        Temperature: \(temperatureCelsius) (Feels like \(String(format: "%.1f°C", feelsLike)))
        Condition: \(condition) - \(description)
        Humidity: \(humidity)%
        Wind Speed: \(String(format: "%.1f m/s", windSpeed))
        """
    }
    
    var emoji: String {
        switch condition.lowercased() {
        case "clear":
            return "☀️"
        case "clouds":
            return "☁️"
        case "rain":
            return "🌧️"
        case "drizzle":
            return "🌦️"
        case "thunderstorm":
            return "⛈️"
        case "snow":
            return "❄️"
        case "mist", "fog", "haze":
            return "🌫️"
        default:
            return "🌤️"
        }
    }
}
