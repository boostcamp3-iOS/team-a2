//
//  WeatherService.swift
//  OneDayProto
//
//  Created by Wongeun Song on 2019. 1. 31..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import Foundation

class WeatherService {
    // MARK: - Properties
    static let service = WeatherService()
    private let baseURL = "https://api.darksky.net/forecast"
    private let APIKey = "9deaa3b4d2ba8a4a3772c6d6015dba6b"
    
    // MARK: - Methods
    func getWeather(latitude: String, longitude: String, success: @escaping (APIWeather) -> Void, errorHandler: @escaping () -> Void) {
        let urlString  = "\(baseURL)/\(APIKey)/\(latitude),\(longitude)"
        guard let url: URL = URL(string: urlString) else { return }
        NetworkProvider.request(url: url, success: success, errorHandler: errorHandler)
    }
}
