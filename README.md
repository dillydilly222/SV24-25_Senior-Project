# FilmPal

FilmPal is an iOS app built with Swift and UIKit that allows users to explore upcoming movies, search for titles, and view detailed information including posters, summaries, genres, release dates, and more. It uses The Movie Database (TMDb) API for fetching real-time movie data.

---

## Features

- Attribution Screen  
  - First-time launch screen with a short wait timer.  
  - Skipped on subsequent app launches.  

- Tabbed Interface  
  - Built using a custom `MainTabBarVC`.  
  - Switch easily between film posters, summaries, and search.  

- Upcoming Movies  
  - Fetches upcoming movies from TMDb in multiple background threads.  
  - Displays posters in a grid (`TitleVC`).  
  - Shows titles and summaries in a table (`SummaryVC`).  

- Movie Search  
  - Search for any movie title with live updates (`SearchVC`).  
  - View posters in a collection view.  

- Movie Details  
  - Select a movie to see detailed information (`SelectedMovieVC`):  
    - Backdrop and poster images.  
    - Overview text.  
    - Genres (mapped from TMDb IDs).  
    - Release date.  
    - Adult content flag.  
    - Language.  

- Core Data Support  
  - Scaffolded for persistence (not actively storing movies yet).  

---

## Tech Stack

- Language: Swift  
- Frameworks: UIKit, CoreData  
- Architecture: Storyboard-based MVC  
- API: [The Movie Database (TMDb)](https://www.themoviedb.org/documentation/api)  

---

## Project Structure

- `AppDelegate.swift` – App lifecycle and Core Data stack.  
- `SceneDelegate.swift` – Scene lifecycle management.  
- `ViewController.swift` – Root view controller handling data fetching and segues.  
- `TitleVC.swift` – Displays movie posters in a collection view.  
- `SummaryVC.swift` – Displays movie summaries in a table view.  
- `SearchVC.swift` – Allows searching for movies.  
- `SelectedMovieVC.swift` – Shows detailed movie information.  
- `AttributionVC.swift` – First-launch attribution screen with timer.  
- `MainTabBarVC.swift` – Custom tab bar controller.  
- `Movie.swift` – Model representing a movie.  
- `MovieResponse.swift` – Model representing a paginated API response.  
- `PosterImageCell.swift` / `summaryCell.swift` / `SearchImageCell.swift` – Custom UI cells for collection and table views.  

---

## Getting Started

### Prerequisites
- macOS with Xcode 15+ installed.  
- A valid TMDb API key.  

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/FilmPal.git
   cd FilmPal
