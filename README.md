# FetchRecipes

A simple recipe application that fetches and displays recipes, focusing on modern architectural patterns, concurrency management, and streamlined image caching.

---

## Steps to Run the App

### Requirements:
- Xcode 16.0+ (built with 16.1)
- iOS 16.0+

1. Clone the repository.
2. Install dependencies using `Swift Package Manager` (SPM).
3. Open the project in Xcode and run it on a simulator or device.

**Note**: To see the various states, go to the `RecipeListView.swift` file and build for previews, and you can see each state.

---

## Features

- **Recipe Fetching**: Retrieves recipes from a remote source and caches them for quick access.
- **Cuisine-Based Filtering**: Users can filter recipes by cuisine to easily find relevant dishes.
- **Image Caching**: Images are cached for efficient loading and minimal network usage.
- **Error Handling**: Displays user-friendly error messages with retry options if data fetching fails.
- **Responsive Design**: Adapts to various screen sizes for an optimal user experience on all devices.

---

## Focus Areas

### 1. **Architecture**
   - The project emphasizes modular, scalable architecture to showcase future-ready design practices. Although scoped for simplicity, the codebase is structured with modular components for **Logging** and **Networking** to support future expansion.
   - **Considerations**:
     - Could be extended by modularizing `FetchRecipes` as a feature-focused module.
     - **Dependency Injection** is implemented using the [Factory](https://github.com/hmlongco/Factory.git) library, promoting flexibility and testability.

### 2. **Concurrency**
   - Swift’s `@MainActor` is used for the `ViewModel`, optimizing UI updates on the main thread.
   - With image caching handled by **Kingfisher**, there was no need to implement custom concurrency patterns like task groups or structured concurrency, simplifying the codebase while keeping it performant.

---

## Time Spent

I spent approximately **6 hours** on this project, allocating time as follows:
- **Architecture Design & Setup**: 40%
- **Data & Business Logic Implementation**: 20%
- **UI Development & Styling**: 20%
- **Testing**: 20%

I worked off an on this, and feel that is a close approximation of total time commited. While I understand it was 4-6 hours, I didn't mind doing it a bit longer. It was fun, and I am proud of what I have came up with.

---

## Trade-offs and Decisions

### 1. **Third-Party Library Access**:
   - To streamline dependency management and CI/CD setup, I chose HTTPS over SSH for pulling libraries, which simplified configuration without needing SSH key management on CI/CD pipelines.

### 2. **Image Caching with Kingfisher**:
   - I opted for [Kingfisher](https://github.com/onevcat/Kingfisher.git) to handle image downloading and caching rather than building a custom solution, as it’s lightweight, performant, and reliable. 
   - If a custom caching solution were implemented, it could involve persisting image data to `FileManager`, fetching locally when available, and only accessing remote resources when necessary.
   
### 3. **Pulled in My Own Flavor of Scalable Networking**:
   - A while back, I needed to create a really generic and scalable networking layer, that allows you to handle success and error responses. I made this during some client work, but later packaged it up into my own private library that I use. I plan to open source it one day, but it's not 100% where I want it just yet.
   
   That being said, I really think it showcases my ability to build scalable frameworks that are easy to use and setup, and are extensible in their own right. I thought it would be good to bring those over into here. It's a lot more lightweight than Alamofire for example, and I think is a pretty solid framework around native URLSession. 
   
   All of that code was copied from my library, and I'm happy to discuss it in depth if desired. 
   
### 4. **Architecture**:
   - I opted for a very lightweight, but extensible variation of the `Clean` architecture pattern, with the foundation laid to abstract the fetch feature into it's own standalone module if desired.
   
#### Presentation Layer

    - **Components**: SwiftUI views and reusable UI components like `EmptyStateView` and `ErrorState`.
    - **MVVM Architecture**: Utilizes MVVM + State approach, which I enjoy working with for SwiftUI views. It's similar to Bloc in Flutter, or TCA.. but without all the bloat.
    
The RecipeListVM is well-designed to manage complex UI state and filtering logic, allowing for an efficient and clean separation of concerns.

The `RecipeListVM` is the primary ViewModel in this project, managing UI state and responding to user interactions. It uses dependency injection for fetching and refreshing data, and it handles view state transitions through a defined `PresentationState` enum. This setup helps keep the UI logic separate from the data and business logic layers, making the ViewModel highly testable and adaptable.

#### Key Elements

- **State Management**: The `PresentationState` enum defines multiple view states:
  - `.empty` for an empty state
  - `.loading` when fetching data
  - `.loaded` with a loaded state containing recipes
  - `.error` for displaying errors
- **Action Dispatching**: The `dispatch` method routes user actions (e.g., `onAppear`, `refresh`, `selectCuisine`) to their respective handlers, ensuring a clear separation of concerns within the ViewModel.
- **Filtering**: The `selectedCuisine` property enables users to filter recipes by cuisine. The `applyFilter()` function applies this filter to dynamically adjust the recipes displayed in the UI.

#### Code Example: `RecipeListVM`

The `RecipeListVM` structure is centered around handling `PresentationState` and actions, making it easy to manage and extend:

```swift
class RecipeListVM: ObservableObject {
    @Injected(\ApplicationContainer.fetchRecipesUseCase) private var fetchRecipesUseCase
    @Injected(\ApplicationContainer.refreshRecipesUseCase) private var refreshRecipesUseCase

    @Published var viewState: PresentationState = .empty
    @Published var selectedCuisine: String? = nil  // Track selected cuisine for filtering

    struct LoadedState: Equatable {
        let recipes: [Recipe]
        let cuisinesList: [String]
    }

    enum PresentationState: Equatable {
        case empty
        case loaded(LoadedState)
        case loading
        case error(ErrorState)
    }

    enum Action {
        case onAppear
        case refresh
        case selectCuisine(String?)
    }
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            fetchRecipes()
        case .refresh:
            refreshRecipes()
        case .selectCuisine(let cuisine):
            selectedCuisine = cuisine
            applyFilter()  // Filter recipes based on selected cuisine
        }
    }
    // rest of code (private to restrict access to view)
}
```

#### Application Layer

    - **Use Cases**: Business logic for fetching and refreshing recipes (`FetchRecipesUseCase` and `RefreshRecipesUseCase`).

#### Data Layer

    - **Models**: Data models like `Recipe` are defined here.
    - **Networking**: The `RecipesNetworkRequester` manages API requests, DTO handling, and response parsing.
    - **Repository**: `RecipesRepository` is responsible for data persistence and caching, abstracting data-fetching logic from the application.
   
### 5. **MVVM**:

---

## Weakest Part of the Project

I believe the weakest part lies in the design, I made a mix of custom components and utilized native SwiftUI components. If given more time, I would have abstracted these a bit more, or even made a DesignSystem module that could be used.

---

## External Code and Dependencies

- **Factory** ([GitHub Link](https://github.com/hmlongco/Factory.git))  
   - Used for dependency injection, enabling loosely coupled, testable code.

- **Kingfisher** ([GitHub Link](https://github.com/onevcat/Kingfisher.git))  
   - A pure-Swift library for downloading and caching images, allowing efficient image handling with minimal custom code.

---

## Bonus Items

The project does utilize GitHub actions to run the tests, and is required to pass.

---
