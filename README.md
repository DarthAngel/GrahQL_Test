# Rick and Morty Explorer

A SwiftUI app that explores the Rick and Morty universe using the [Rick and Morty GraphQL API](https://rickandmortyapi.com/graphql). Built with SwiftUI, SwiftData, and modern concurrency.

## Features

- Browse locations, characters, and episodes from the Rick and Morty universe
- Offline support with local caching using SwiftData
- Infinite scrolling pagination
- Search functionality
- Detailed character profiles

## Project Structure

- `GrahQL_Test/`
  - `Models/` - Data models (Character, Location, Episode)
  - `ViewModels/` - View models for data handling
  - `Views/` - SwiftUI views
  - `Services/` - API service and networking
  - `Utils/` - Utilities and helpers
- `GrahQL_TestTests/` - Unit tests
- `GrahQL_TestUITests/` - UI tests

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/GrahQL_Test.git
   ```
2. Open `GrahQL_Test.xcodeproj` in Xcode 15 or later
3. Build and run the project (⌘ + R)

## Dependencies

- **SwiftUI** - For building the user interface
- **SwiftData** - For local data persistence
- **Combine** - For reactive programming
- **Swift Concurrency** - For async/await patterns

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Represent the data and business logic
- **ViewModels**: Handle data preparation and business logic for views
- **Views**: Present the UI and handle user interactions

## API Usage

The app uses the public Rick and Morty GraphQL API:
- Base URL: `https://rickandmortyapi.com/graphql`
- No API key required
- Rate limiting: 100 requests per minute

## Testing

Run tests using Xcode's Test navigator (⌘ + 6) or press ⌘ + U to run all tests.

### Running Tests

1. Unit Tests: `⌘ + U`
2. UI Tests: Use the Test navigator to run specific UI tests

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgments

- [The Rick and Morty API](https://rickandmortyapi.com/)
- Apple's SwiftUI and SwiftData documentation
