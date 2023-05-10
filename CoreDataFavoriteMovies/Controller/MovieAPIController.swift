//
//  MovieAPIController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/1/22.
//

import Foundation


class MovieAPIController {
    
    enum DataResponseError: Error, LocalizedError {
        case itemNotFound
    }
    
    let baseURL = URL(string: "http://www.omdbapi.com/")!
    let apiKey = "d88bd3c6"
    
    func fetchMovies(with searchTerm: String) async throws -> [APIMovie] {
        let apiKeyItem = URLQueryItem(name: "apiKey", value: apiKey)
        let apiSearchItem = URLQueryItem(name: "s", value: searchTerm)
        
        var urlComponents = URLComponents(string: "\(baseURL)")!
        urlComponents.queryItems = [
            apiKeyItem,
            apiSearchItem
            ]
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw DataResponseError.itemNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let searchResponse = try jsonDecoder.decode(SearchResponse.self, from: data)
        
        return searchResponse.movies
    }
}
