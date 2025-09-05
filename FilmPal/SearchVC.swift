import UIKit

class SearchVC: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var movieSearchCollectionView: UICollectionView!
    @IBOutlet weak var searchFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Properties
    
    let apiKey = "your-api-key-here"
    let baseURL = "https://api.themoviedb.org/3"
    let baseImageURL = "https://image.tmdb.org/t/p/original"
    
    let dispatchGroup = DispatchGroup()
    
    var movieSearchedPosters: [UIImage] = []
    var movieTitle: String = ""
    var movieOrder: [String] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        movieSearchBar.delegate = self
        movieSearchCollectionView.delegate = self
        movieSearchCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchFlowLayout.scrollDirection = .vertical
        searchFlowLayout.minimumLineSpacing = 0
        searchFlowLayout.minimumInteritemSpacing = 0
        searchFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = movieSearchCollectionView.frame.size.width/3
        let scaledImage = scaleImage(movieSearchedPosters[indexPath.item], scale: 0.3)
        let cellHeight = scaledImage!.size.height
        let finalImage = scaleImageWidthHeight(movieSearchedPosters[indexPath.item], width: cellWidth, height: cellHeight)
        return CGSizeMake(cellWidth, finalImage!.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieSearchedPosters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = movieSearchCollectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchImageCell
        let cellWidth = movieSearchCollectionView.frame.size.width/3
        let scaledImage = scaleImage(movieSearchedPosters[indexPath.item], scale: 0.34)
        let cellHeight = scaledImage!.size.height
        let finalImage = scaleImageWidthHeight(movieSearchedPosters[indexPath.item], width: cellWidth, height: cellHeight-30)
        cell.searchedMoviePoster.backgroundColor = UIColor(patternImage: finalImage!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movieOrder[indexPath.item]
        print(selectedMovie)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedMovieVC = storyboard.instantiateViewController(withIdentifier: "SelectedMovieVC") as! SelectedMovieVC
        selectedMovieVC.movieTitle = selectedMovie
        navigationController?.pushViewController(selectedMovieVC, animated: true)
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            movieSearchedPosters.removeAll()
            movieSearchCollectionView.reloadData()
        } else {
            movieSearchedPosters.removeAll()
            movieTitle = searchText.uppercased()
            movieTitle = movieTitle.replacingOccurrences(of: " ", with: "%")
            Task {
                do {
                    var pageNumber = 1
                    while (pageNumber < 2) {
                        print(movieTitle)
                        let movieList = try await loadSearchedMovies(link:"\(baseURL)/search/movie?api_key=\(apiKey)&query=\(movieTitle)")
                        for movie in movieList {
                            let moviePosterPath = try await fetchPosterPath(movieID: movie.id)
                            let moviePosterLink = "https://image.tmdb.org/t/p/w500\(moviePosterPath ?? "none")"
                            loadImage(from: moviePosterLink) { image in
                                if let image = image {
                                    self.movieSearchedPosters.append(image)
                                    self.movieOrder.append(movie.title)
                                } else {
                                    //print("NO IMAGE")
                                }
                            }
                        }
                        pageNumber += 1
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.movieSearchCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Worked")
        self.view.endEditing(true)
        self.movieSearchCollectionView.reloadData()
    }
    
    // MARK: - API Request
    
    func loadSearchedMovies(link: String) async throws -> [Movie] {
        let url = URL(string: link)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decoded.results
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func scaleImage(_ image: UIImage, scale: CGFloat) -> UIImage? {
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: size)
        let scaledImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return scaledImage
    }
    
    func scaleImageWidthHeight(_ image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let scaledImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return scaledImage
    }
    
    func fetchBackdropPath(movieID: Int) async throws -> String? {
        let baseURL = "https://api.themoviedb.org/3"
        let endpoint = "\(baseURL)/movie/\(movieID)?api_key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw MovieError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if !data.isEmpty {
            let movie = try JSONDecoder().decode(Movie.self, from: data)
            return movie.backdrop_path
        } else {
            throw MovieError.noData
        }
    }
    
    func fetchPosterPath(movieID: Int) async throws -> String? {
        let baseURL = "https://api.themoviedb.org/3"
        let endpoint = "\(baseURL)/movie/\(movieID)?api_key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw MovieError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if !data.isEmpty {
            let movie = try JSONDecoder().decode(Movie.self, from: data)
            return movie.poster_path
        } else {
            throw MovieError.noData
        }
    }
}

extension SearchVC {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
