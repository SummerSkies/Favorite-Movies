//
//  MovieController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/1/22.
//

import Foundation
import CoreData

class MovieController {
    static let shared = MovieController()
    
    private let apiController = MovieAPIController()
    private var viewContext = PersistenceController.shared.viewContext
    
    func fetchMovies(with searchTerm: String) async throws -> [APIMovie] {
        return try await apiController.fetchMovies(with: searchTerm)
    }
    
    func fetchFavorites(searchTerm: String) -> [Movie] {
        let request: NSFetchRequest = Movie.fetchRequest()
        let context = PersistenceController.shared.viewContext
        
        if !searchTerm.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS %@", searchTerm)
        }
        
        return (try? context.fetch(request)) ?? []
    }
    
    func favoriteMovie(_ movie: APIMovie) {
        let newFavorite = Movie(context: viewContext)
        newFavorite.title = movie.title
        newFavorite.imdbID = movie.imdbID
        newFavorite.year = movie.year
        newFavorite.posterURL = "\(movie.posterURL!)"
        
        PersistenceController.shared.saveContext()
    }
    
    func unfavoriteMovie(_ movie: Movie) {
        viewContext.delete(movie)
        PersistenceController.shared.saveContext()
    }
    
    func favoriteMovie(from movie: APIMovie) -> Movie? {
        let request: NSFetchRequest = Movie.fetchRequest()
        request.predicate = NSPredicate(format: "imdbID = %@", movie.id)
        return try? viewContext.fetch(request).first
    }
}
