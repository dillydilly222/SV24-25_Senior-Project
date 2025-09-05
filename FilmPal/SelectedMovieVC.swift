import UIKit

class SelectedMovieVC: UIViewController {
    
    // MARK: - Properties
    
    let apiKey = "your-api-key-here"
    let baseURL = "https://api.themoviedb.org/3"
    let baseImageURL = "https://image.tmdb.org/t/p/original"
    
    var movieId: Int = 0
    var movieTitle: String = ""
    var moviePoster: String = ""
    var movieBackdrop: String = ""
    var movieOverview: String = ""
    var movieAdult: Bool = false
    var movieGenres: [Int] = []
    var movieReleaseDate: String = ""
    var movieLanguage: String = ""
    
    // MARK: - Outlets
    
    @IBOutlet weak var movieBackdropIV: UIImageView!
    @IBOutlet weak var moviePosterIV: UIImageView!
    @IBOutlet weak var movieOverviewTextView: UITextView!
    @IBOutlet weak var movieGenreLabel: UILabel!
    @IBOutlet weak var movieAdultLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    @IBOutlet weak var movieLanguageLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMovieDetails()
    }
    
    // MARK: - Methods
    
    func fetchMovieDetails() {
        Task {
            do {
                let movieList = try await loadSelectedMovie(link: "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(movieTitle)")
                let movie = movieList.first
                movieTitle = movie?.title ?? "N/A"
                movieOverview = movie?.overview ?? "N/A"
                movieAdult = movie?.adult ?? false
                movieGenres = movie?.genre_ids ?? [1]
                movieReleaseDate = movie?.release_date ?? "00-00-0000"
                movieLanguage = movie?.original_language ?? "N/A"
                
                self.title = movieTitle
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Chalkboard SE Regular", size: 20)!]
                
                let backdropPath =  try await fetchBackdropPath(movieTitle: movieTitle)
                let backdropLink = "https://image.tmdb.org/t/p/w500\(backdropPath ?? "none")"
                loadImage(from: backdropLink) { image in
                    if let image = image {
                        self.movieBackdropIV.image = self.scaleImageWidthHeight(image, width: self.movieBackdropIV.frame.width, height: self.movieBackdropIV.frame.height)
                    } else {
                        self.movieBackdropIV.backgroundColor = UIColor.black //replace with generic image
                    }
                }
                
                let posterPath =  try await fetchPosterPath(movieTitle: movieTitle)
                let posterLink = "https://image.tmdb.org/t/p/w500\(posterPath ?? "none")"
                loadImage(from: posterLink) { image in
                    if let image = image {
                        self.moviePosterIV.image = self.scaleImageWidthHeight(image, width: self.moviePosterIV.frame.width, height: self.moviePosterIV.frame.height)
                    } else {
                        self.moviePosterIV.backgroundColor = UIColor.black //replace with generic image
                    }
                }
                movieOverviewTextView.text = movieOverview
                var movieGenreString = ""
                if movieGenres.count > 1 {
                    movieGenreString = "Genres:"
                } else {
                    movieGenreString = "Genre:"
                }
                for genre in movieGenres {
                    switch genre {
                    case 12:
                        movieGenreString += " Adventure,"
                    case 14:
                        movieGenreString += " Fantasy,"
                    case 16:
                        movieGenreString += " Animation,"
                    case 18:
                        movieGenreString += " Drama,"
                    case 27:
                        movieGenreString += " Horror,"
                    case 28:
                        movieGenreString += " Action,"
                    case 35:
                        movieGenreString += " Comedy,"
                    case 36:
                        movieGenreString += " History,"
                    case 37:
                        movieGenreString += " Western,"
                    case 53:
                        movieGenreString += " Thriller,"
                    case 80:
                        movieGenreString += " Crime,"
                    case 99:
                        movieGenreString += " Documentary,"
                    case 878:
                        movieGenreString += " Science Fiction,"
                    case 9648:
                        movieGenreString += " Mystery,"
                    case 10402:
                        movieGenreString += " Music,"
                    case 10749:
                        movieGenreString += " Romance,"
                    case 10751:
                        movieGenreString += " Family,"
                    case 10752:
                        movieGenreString += " War,"
                    case 10770:
                        movieGenreString += " TV Movie,"
                    default:
                        movieGenreString += ""
                    }
                }
                if (movieGenreString == "Genre:" || movieGenreString == "Genres:") {
                    movieGenreString += " NONE"
                    movieGenreLabel.text = movieGenreString
                } else {
                    movieGenreString.removeLast()
                    movieGenreLabel.text = movieGenreString
                    if (movieGenreLabel.text!.count > 40) {
                        movieGenreLabel.font = UIFont.systemFont(ofSize: UIScreen.main.bounds.width/30)
                    }
                }
                
                if (movieAdult) {
                    movieAdultLabel.text = "Adult: Yes"
                } else {
                    movieAdultLabel.text = "Adult: No"
                }
                
                movieReleaseDateLabel.text = "Release Date: \(movieReleaseDate)"
                
                switch movieLanguage {
                case "en":
                    movieLanguageLabel.text = "Language: English"
                case "es":
                    movieLanguageLabel.text = "Language: Spanish"
                case "ja":
                    movieLanguageLabel.text = "Language: Japanese"
                case "zh":
                    movieLanguageLabel.text = "Language: Chinese"
                default:
                    movieLanguageLabel.text = "Language: N/A"
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func loadSelectedMovie(link: String) async throws -> [Movie] {
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
    
    func fetchBackdropPath(movieTitle: String) async throws -> String? {
        let baseURL = "https://api.themoviedb.org/3"
        let formattedTitle = movieTitle.replacingOccurrences(of: " ", with: "%20")
        let endpoint = "\(baseURL)/search/movie?query=\(formattedTitle)&api_key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw MovieError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if !data.isEmpty {
            let searchResults = try JSONDecoder().decode(MovieResponse.self, from: data)
            if let movie = searchResults.results.first {
                return movie.backdrop_path
            } else {
                throw MovieError.noData
            }
        } else {
            throw MovieError.noData
        }
    }
    
    func fetchPosterPath(movieTitle: String) async throws -> String? {
        let baseURL = "https://api.themoviedb.org/3"
        let formattedTitle = movieTitle.replacingOccurrences(of: " ", with: "%20")
        let endpoint = "\(baseURL)/search/movie?query=\(formattedTitle)&api_key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw MovieError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if !data.isEmpty {
            let searchResults = try JSONDecoder().decode(MovieResponse.self, from: data)
            if let movie = searchResults.results.first {
                return movie.poster_path
            } else {
                throw MovieError.noData
            }
        } else {
            throw MovieError.noData
        }
    }
}
