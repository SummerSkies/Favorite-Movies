//
//  FavoritesViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/3/22.
//

import UIKit
import CoreData

@MainActor
class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    private let movieController = MovieController.shared
    
    private var datasource: UITableViewDiffableDataSource<Int, Movie>!
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search favorites"
        sc.searchBar.delegate = self
        return sc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDataSource()
        tableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
    }
    
    func fetchFavorites() {
        let searchTerm = searchController.searchBar.text ?? ""
        let objects = movieController.fetchFavorites(searchTerm: searchTerm)
        applyNewSnapshot(from: objects)
    }
    
    func removeFavorite(_ movie: Movie) {
        MovieController.shared.unfavoriteMovie(movie)
        var snapshot = datasource.snapshot()
        snapshot.deleteItems( [movie] )
        datasource?.apply(snapshot, animatingDifferences: true)
    }
}

private extension FavoritesViewController {
    
    func setUpTableView() {
        tableView.backgroundView = backgroundView
    }
    
    func toggleFavorite(_ movie: Movie) {
        movieController.unfavoriteMovie(movie)
        fetchFavorites()
    }
    
    func setUpDataSource() {
        datasource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { tableView, indexPath, movie in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
            cell.update(with: movie) {
                self.toggleFavorite(movie)
            }
            return cell
        }
    }
    
    func applyNewSnapshot(from movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        datasource?.apply(snapshot, animatingDifferences: true)
        tableView.backgroundView = movies.isEmpty ? backgroundView : nil
    }
}

extension FavoritesViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.isEmpty {
            fetchFavorites()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchFavorites()
    }
    
}
