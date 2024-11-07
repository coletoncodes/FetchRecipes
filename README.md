# FetchRecipes

### Steps to Run the App

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
1. Architecture

I prioritized architecture because that is what I am the most passionate about, and even though it was a simple application, I wanted to showcase some modern practices and set it up for future development work.

It has modularization with the Logging Library and the Networking Foundation, but if desired you could take a further step to make the fetch recipes a "feature" scoped module. I opted not to do that with this project.

2. Concurrency
The concurrency piece of this was fairly straight forward, but I did utilize MainActor for the ViewModel. Since the caching of images is handled by the KingFisher library, I did not need to introduce complex task groups, or structured concurrency.

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
1. For Third Party libraries, I opted to use https to save time managing SSH keys on CCI runs for the project.
2. KingFisher instead of rolling my own image caching service.

    - If I added my own ImageCaching, it would consist of persisting the image data to FileManager, and would simply check for a stored file location to retrieve the image data from, else begin to fetch from remote and save it that way.

### Weakest Part of the Project: What do you think is the weakest part of your project?


### External Code and Dependencies: Did you use any external code, libraries, or dependencies?

- [Factory](git@github.com:hmlongco/Factory.git)
    - A new approach to Container-Based Dependency Injection for Swift and SwiftUI.
- [Kingfisher](https://github.com/onevcat/Kingfisher.git)
    - A lightweight, pure-Swift library for downloading and caching images from the web.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
