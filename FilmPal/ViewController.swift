// MARK: - Imports

import UIKit

// MARK: - ViewController

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var filmContainerView: UIView!
    @IBOutlet weak var summaryContainerView: UIView!
    
    // MARK: - Properties
    
    let apiKey = "your-api-key-here"
    let baseURL = "https://api.themoviedb.org/3"
    let baseImageURL = "https://image.tmdb.org/t/p/original"
    var moviePosterImageListT: [UIImage] = []
    var movieOverviewsT: [String] = []
    var movieTitlesT: [String] = []
    var topMoviesOrderT: [String] = []
    var moviePosterImageLinks: [String] = []
    let dispatchGroup = DispatchGroup()
    var threadsFinished = false
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        dispatchGroup.enter()
        DispatchQueue.global().async { [weak self] in
            self?.loadData1()
        }
        
        dispatchGroup.enter()
        DispatchQueue.global().async { [weak self] in
            self?.loadData2()
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            print("threads finished")
            self!.threadsFinished = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filmContainerView.alpha = 1
        summaryContainerView.alpha = 0
    }
    
    // MARK: - Actions
    
    @IBAction func changeViewPressed(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            filmContainerView.alpha = 1
            summaryContainerView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            filmContainerView.alpha = 0
            summaryContainerView.alpha = 1
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filmConnection" {
            let titleVC = segue.destination as! TitleVC
            titleVC.mainVC = self
        }
        
        if segue.identifier == "summaryConnection" {
            let summaryVC = segue.destination as! SummaryVC
            summaryVC.mainVC = self
        }
    }
    
    // MARK: - Data Loading
    
    func loadData1() {
        Task {
            do {
                var pageNumber = 1
                while pageNumber < 6 {
                    let movieList = try await loadTopMovies(link: "\(baseURL)/movie/upcoming?api_key=\(apiKey)&page=\(pageNumber)")
                    for movie in movieList {
                        let moviePosterPath = try await fetchPosterPath(movieID: movie.id)
                        let moviePosterLink = "https://image.tmdb.org/t/p/w500\(moviePosterPath ?? "none")"
                        loadImage(from: moviePosterLink) { image in
                            if let image = image {
                                self.moviePosterImageLinks.append(moviePosterLink)
                                self.moviePosterImageListT.append(image)
                                self.movieOverviewsT.append(movie.overview ?? "Movie Summary Not Available")
                                self.movieTitlesT.append(movie.title)
                                self.topMoviesOrderT.append(movie.title)
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
            dispatchGroup.leave()
        }
    }
    
    func loadData2() {
        Task {
            do {
                var pageNumber = 5
                while pageNumber < 11 {
                    let movieList = try await loadTopMovies(link: "\(baseURL)/movie/upcoming?api_key=\(apiKey)&page=\(pageNumber)")
                    for movie in movieList {
                        let moviePosterPath = try await fetchPosterPath(movieID: movie.id)
                        let moviePosterLink = "https://image.tmdb.org/t/p/w500\(moviePosterPath ?? "none")"
                        loadImage(from: moviePosterLink) { image in
                            if let image = image {
                                self.moviePosterImageLinks.append(moviePosterLink)
                                self.moviePosterImageListT.append(image)
                                self.movieOverviewsT.append(movie.overview ?? "Movie Summary Not Available")
                                self.movieTitlesT.append(movie.title)
                                self.topMoviesOrderT.append(movie.title)
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
            dispatchGroup.leave()
        }
    }
    
    // MARK: - API Requests
    
    func loadTopMovies(link: String) async throws -> [Movie] {
        let url = URL(string: link)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decoded.results
    }
    
    func fetchBackdropPath(movieID: Int) async throws -> String? {
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
    
    // MARK: - Image Loading
    
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
    
    // MARK: - Image Scaling
    
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
    
} // End of class
