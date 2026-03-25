# Project: contact-ios

An iOS app for browsing device contacts, built with UIKit using programmatic UI.

## Architecture

**Pattern:** MVVM + Repository

```
View (UIViewController)
  └── ViewModel (@MainActor class)
        └── Repository (protocol + actor implementation)
              └── Service (Contacts framework)
```

- `View/` — UIViewControllers, no storyboards
- `ViewModel/` — `@MainActor` classes, holds state and business logic
- `Repository/` — protocol-based, implemented as `actor` for thread safety
- `Service/` — wraps Apple's `Contacts` framework
- `Components/` — reusable UIView subclasses and cells
- `Model/` — value types (`struct`), `Hashable`, `Sendable`
- `Manager/` — singletons (e.g. `ImageCacheManager`)

## Key Conventions

- **No storyboards, no XIBs** — all UI is programmatic
- **No IBOutlets/IBActions** — use `addTarget`, `NSLayoutConstraint`, etc.
- **Swift Concurrency** — use `async/await`, not completion handlers or `DispatchQueue` (except for third-party lib calls)
- **`@MainActor`** on ViewModels; `actor` for repository implementations
- **`translatesAutoresizingMaskIntoConstraints = false`** on every programmatic view
- Cell identifiers use a static `identifier` property on the cell class
- ViewControllers receive dependencies via constructor injection (no singletons in VCs)

## Current Active Screen

`CompositionalLayoutViewController` is the root view controller (set in `SceneDelegate`).
It uses:
- `UICollectionViewCompositionalLayout`
- `UICollectionViewDiffableDataSource<Section, ContactModel>`
- `UISearchController` for live search (debounced via `Task` cancellation)
- Infinite scroll via `scrollViewDidScroll` + `loadNextPage()`

## Dependencies

- `GDPerformanceView-Swift` — performance overlay shown in SceneDelegate on launch

## Data Flow

1. `ContactPermissionManager` requests/checks `CNContactStore` permission
2. `ContactServiceImpl` fetches all contacts from the device
3. `ContactRepositoryImpl` (actor) caches contacts in-memory by ID
4. `ContactListViewModel` holds paginated state (50 contacts per page)
5. ViewController applies snapshots via `NSDiffableDataSourceSnapshot`


## Build and Test
