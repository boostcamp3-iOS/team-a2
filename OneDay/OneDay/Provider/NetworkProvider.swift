//
//  NetworkProvider.swift
//  OneDay
//
//  Created by Wongeun Song on 2019. 1. 31..
//  Copyright © 2019년 teamA2. All rights reserved.
//

import UIKit

final class NetworkProvider {
    
    static func request<DecodeType: Decodable>(
        url: URL,
        success: @escaping (DecodeType) -> Void,
        errorHandler: @escaping () -> Void
    ) {
        let session: URLSession = URLSession(configuration: .default)
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        let dataTask: URLSessionDataTask = session.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            if let error = error {
                errorHandler()
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let apiResponse: DecodeType = try JSONDecoder().decode(DecodeType.self, from: data)
                success(apiResponse)
            } catch {
                errorHandler()
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
}
