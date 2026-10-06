
https://github.com/user-attachments/assets/a3ec6945-3e7d-40f4-8a22-d31ca7611fb2

# Gapsi Product Search

Native iOS app that searches the Walmart catalog through the Axesso API on RapidAPI.

- iOS 16+, Swift 6 (strict concurrency), SwiftUI, no third-party dependencies.
- Built with Xcode 26.5.

## Configuration

1. Copy the secrets template:
   ```sh
   cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
   ```
2. Replace `your-rapidapi-key-here` in `Config/Secrets.xcconfig` with your RapidAPI key.
3. Open `gapsi.xcodeproj` and run the `gapsi` scheme.

If the key is missing or still the placeholder, the app opens a configuration screen instead of crashing.

`Config/Secrets.xcconfig` is git-ignored. The key reaches the app via `Config/Base.xcconfig` → `$(RAPIDAPI_KEY)` in `Info.plist` → `AppConfiguration`.

### Tests

- Domain and data layers: `cd GapsiKit && swift test`
- ViewModels: `⌘U` in Xcode (`gapsiTests` target)

## Architecture

Clean Architecture with MVVM. The dependency rule is enforced by modules, not by convention.

| Layer | Location | Depends on |
|---|---|---|
| Domain | `GapsiKit/Sources/Domain` | Foundation only |
| DataLayer | `GapsiKit/Sources/DataLayer` | Domain |
| Presentation | `gapsi/Presentation` | Domain |
| Composition root | `gapsi/App` | Domain, DataLayer |

- **Domain**: entities, pure rules (`ProductPaginator`, `SearchHistory`), repository protocols and use cases. No I/O.
- **DataLayer**: URLSession client, DTOs and mapper, repository implementations. Only repositories and the HTTP client are public.
- **Presentation**: SwiftUI views and `@MainActor` ViewModels. Never imports DataLayer.
- **App**: `AppContainer` wires concrete implementations; it is the only place that knows them.

## Decisions

### Concurrency
- Default actor isolation is `nonisolated` and approachable concurrency is off. Network calls and JSON decoding (~1 MB responses) run off the main thread; only Presentation is `@MainActor`.
- All domain and data types are `Sendable` without `@unchecked`. Test fakes use `OSAllocatedUnfairLock`.
- A new search cancels the in-flight one. Late responses are discarded, so results never mix between searches.

### Pagination
- `ProductPaginator` owns pagination state per search: next page, end detection, and deduplication by product id.
- Only `GRID` stacks are mapped. Carousels contain recommendations and duplicates.
- The API never reports its own end. The page count is read from page 1 only (later pages report inconsistent values), and an empty grid ends pagination.
- A page made only of duplicates loads the next one automatically, so scrolling never stalls.
- A failed page keeps loaded products and shows an inline retry.

### Network and performance
- Search runs on submit, not while typing, to protect the API quota.
- The API uses its own `URLSession` with no cache and a 20 s timeout, so results are always fresh.
- `URLCache.shared` (50 MB memory, 200 MB disk) is reserved for thumbnails loaded by `AsyncImage`.
- Prices are decoded as `Decimal` and rounded to 2 places, avoiding binary floating-point noise on older runtimes.

### Errors
- DataLayer maps HTTP and transport failures to `ProductRepositoryError` (connectivity, unauthorized, rate limited, server, invalid data). HTTP details never leave DataLayer.
- Cancellation is rethrown as `CancellationError` and never shown as an error.

### Search history
- Stored in `UserDefaults`, most recent first, case-insensitive deduplication, limit of 20 terms.
- Rules live in Domain (`SearchHistory`); the repository only stores the list.
- History operations are synchronous on purpose: they run on the MainActor, which serializes load-modify-save.

### Localization
- User-facing text lives in `Localizable.xcstrings` with English as the source language.

## Known limitations

- The API key ships inside the app bundle. A production app would call its own backend, which holds the key.
- Clearing the search field keeps the last results; history stays available from the search suggestions.
- Product detail and navigation are out of scope.
