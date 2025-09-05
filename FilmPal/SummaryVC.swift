import UIKit

class SummaryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    
    @IBOutlet weak var summaryTableView: UITableView!
    
    // MARK: - Properties
    
    var movieOverviews: [String] = []
    var movieTitles: [String] = []
    var topMoviesOrder: [String] = []
    var cellHeight: CGFloat = 50
    var movieLinks: [String] = []
    let apiKey = "your-api-key-here"
    let baseURL = "https://api.themoviedb.org/3"
    let baseImageURL = "https://image.tmdb.org/t/p/original"
    let dispatchGroup = DispatchGroup()
    var totalPages = 44
    var mainVC: ViewController!
    var loadTimer : Timer!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(check), userInfo: nil, repeats: true)
    }
    
    // MARK: - Timer Action
    
    @objc func check(){
        if mainVC.threadsFinished {
            movieTitles = (mainVC.movieTitlesT)
            movieOverviews = (mainVC.movieOverviewsT)
            topMoviesOrder = (mainVC.topMoviesOrderT)
            summaryTableView.delegate = self
            summaryTableView.dataSource = self
            summaryTableView.reloadData()
            loadTimer.invalidate()
            loadTimer = nil
        }
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = summaryTableView.dequeueReusableCell(withIdentifier: "Summary Cell", for: indexPath) as! summaryCell
        cell.titleLabel.textAlignment = .center
        cell.titleLabel.frame.size.width = 343
        cell.titleLabel.text = movieTitles[indexPath.row]
        cell.overviewTextView.text = movieOverviews[indexPath.row]
        cell.overviewTextView.sizeToFit()
        cellHeight = cell.overviewTextView.frame.height + cell.titleLabel.frame.height + 20
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = topMoviesOrder[indexPath.item]
        print(selectedMovie)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectedMovieVC = storyboard.instantiateViewController(withIdentifier: "SelectedMovieVC") as! SelectedMovieVC
        selectedMovieVC.movieTitle = selectedMovie
        navigationController?.pushViewController(selectedMovieVC, animated: true)
    }
    
    // MARK: - API Request
    
    func loadTopMovies(link: String) async throws -> [Movie] {
        let url = URL(string: link)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(MovieResponse.self, from: data)
        return decoded.results
    }
    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
