# Networking
A simple networking library using URLSession to use inside of Swift packages and apps.

This was copied from a private library that I have built, and plan to open source soon. To save time, I have just copied the necessary files here.

I can discuss this repo more in depth if required, and show it on GitHub if desired.

## Overview
This project provides a comprehensive Swift-based network layer designed for iOS applications. It encapsulates all the necessary components to make API requests and handle responses in a robust and scalable manner. The design leverages Swift protocols and generics, enabling a highly modular and testable architecture.

## Features
- **Protocol-Oriented Design**: Leverages Swift's protocol-oriented programming to ensure modularity and flexibility.
- **Generic Network Requesting**: Allows for type-safe requests and responses using generic types.
- **Custom Error Handling**: Includes detailed error handling tailored to various network scenarios.
- **Decoder and Encoder Integration**: Integrates `JSONEncoder` and `JSONDecoder` to seamlessly handle JSON data.
- **Unit Testing Friendly**: Designed to support mocking and unit testing by abstracting URLSession functionalities.

## Key Components
- **`NetworkRequest`**: Protocol defining the blueprint for network requests including the method, path, headers, and body.
- **`NetworkHeader`**: Struct representing HTTP headers.
- **`HTTPMethod`**: Enum defining supported HTTP methods.
- **`NetworkRequestError` and `NetworkRequesterError`**: Enums for handling various network request errors.
- **`NetworkResponse`**: Enum handling the responses by either capturing a successful response or an error response.
- **`NetworkRequester`**: Main class responsible for performing network requests using a provided session and encoder.
- **`URLSessionProtocol`**: Protocol allowing for URLSession mocking, aiding in unit testing.

## Usage

### Setup
To set up the network layer in your project, follow these steps:
1. **Define Request and Response Types**: Create structs or classes conforming to `Decodable` for your API responses, and if needed, conform to `Encodable` for your request bodies.
2. **Implement `NetworkRequest`**: Create specific request types for different endpoints by conforming to the `NetworkRequest` protocol.
3. **Configure `NetworkRequester`**: Initialize `NetworkRequester` with a `JSONEncoder` and a session conforming to `URLSessionProtocol`.

### Example
Here is an example of how to set up and use the network layer to fetch activities from an API:
```swift
// Define your API response structure
struct ActivityDTO: Decodable {
    var id: String
    var name: String
}

// Define the request type
struct GetActivitiesRequest: NetworkRequest {
    typealias SuccessResponse = [ActivityDTO]
    typealias ErrorResponse = SimpleErrorResponse // Define this according to your API

    var body: Encodable? { nil }
    var method: HTTPMethod { .GET }
    var path: String { "https://api.example.com/activities" }
    var headers: [NetworkHeader] { [.jsonContentType] }
}

// Implement the response handler
final class ActivitiesResponseHandler<T: Decodable>: NetworkResponseHandler {
    typealias SuccessResponse = T
    typealias ErrorResponse = SimpleErrorResponse

    var decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        this.decoder = decoder
    }

    func handleResponse(statusCode: Int, responseData: Data) async throws -> NetworkResponse<T, SimpleErrorResponse> {
        // Handle response based on status code and decode data
        guard statusCode >= 200 && statusCode < 300 else {
            do {
                let errorResponse: ErrorResponse = try decoder.decodeResponse(
                    ErrorResponse.self,
                    from: responseData
                )
                return .errorResponse(errorResponse)
            } catch {
                log("Failed to decode error response with error: \(error)", .error, .networking)
                throw error
            }
        }
    }
}

// Use in your networking layer
final class ActivitiesNetworkRequester: ActivitiesNetworkRequesting {
    @Injected(\.networkRequesting) private var requester
    @Injected(\.jsonDecoder) private var decoder
    
    func getActivities() async throws -> NetworkResponse<[ActivityDTO], SimpleErrorResponse> {
        do {
            let responseHandler = ActivitiesResponseHandler<GetActivitiesRequest.SuccessResponse>(decoder: decoder)
            return try await requester.performRequest(GetActivitiesRequest(), responseHandler: responseHandler)
        } catch {
            log("Failed to handle request with error: \(error)", .error, .networking)
            throw error
        }
    }
}
