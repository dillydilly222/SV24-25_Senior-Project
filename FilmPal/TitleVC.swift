import UIKit

enum MovieError: Error {
    case invalidURL
    case noData
    case decodingError
}

class TitleVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    
    @IBOutlet weak var posterCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Properties
    
    let apiKey = "your-api-key-here"
    let baseURL = "https://api.themoviedb.org/3"
    let baseImageURL = "https://image.tmdb.org/t/p/original"
    var moviePosterImageList: [UIImage] = []
    var topMoviesOrder: [String] = []
    let dispatchGroup = DispatchGroup()
    var totalPages = 44
    var loadTimer : Timer!
    var mainVC: ViewController!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(check), userInfo: nil, repeats: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Timer Action
    
    @objc func check(){
        if mainVC.threadsFinished {
            moviePosterImageList = (mainVC.moviePosterImageListT)
            topMoviesOrder = (mainVC.topMoviesOrderT)
            posterCollectionView.delegate = self
            posterCollectionView.dataSource = self
            posterCollectionView.reloadData()
            loadTimer.invalidate()
            loadTimer = nil
        }
    }
    
    // MARK: - Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moviePosterImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = posterCollectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath) as! PosterImageCell
        let cellWidth = posterCollectionView.frame.size.width/3
        let scaledImage = scaleImage(moviePosterImageList[indexPath.item], scale: 0.34)
        let cellHeight = scaledImage!.size.height
        let finalImage = scaleImageWidthHeight(moviePosterImageList[indexPath.item], width: cellWidth, height: cellHeight-30)
        cell.posterImageView.backgroundColor = UIColor(patternImage: finalImage!)
        return cell
    }
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = topMoviesOrder[indexPath.item]
        print(selectedMovie)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedMovieVC = storyboard.instantiateViewController(withIdentifier: "SelectedMovieVC") as! SelectedMovieVC
        selectedMovieVC.movieTitle = selectedMovie
        navigationController?.pushViewController(selectedMovieVC, animated: true)
    }
    
    // MARK: - Collection View Flow Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = posterCollectionView.frame.size.width/3
        let scaledImage = scaleImage(moviePosterImageList[indexPath.item], scale: 0.3)
        let cellHeight = scaledImage!.size.height
        let finalImage = scaleImageWidthHeight(moviePosterImageList[indexPath.item], width: cellWidth, height: cellHeight)
        return CGSize(width: cellWidth, height: finalImage!.size.height)
    }
    
    // MARK: - API Request
    
    func loadTopMovies(link: String) async throws -> [Movie] {
        let url = URL(string: link)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decoded.results
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
    
}
