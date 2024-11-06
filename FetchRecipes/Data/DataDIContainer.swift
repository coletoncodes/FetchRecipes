//
//  DataDIContainer.swift
//  FetchRecipes
//
//  Created by Coleton Gorecke on 11/6/24.
//

import Factory
import Foundation
import Networking

public final class DataContainer: SharedContainer {
     public static let shared = DataContainer()
     public let manager = ContainerManager()
}

extension DataContainer {
    var jsonDecoder: Factory<JSONDecoder> {
        self { JSONDecoder() }
            .cached
    }

    var jsonEncoder: Factory<JSONEncoder> {
        self { JSONEncoder() }
            .cached
    }

    var urlSession: Factory<URLSessionProtocol> {
        self { URLSession.shared }
            .cached
    }

    var networkRequester: Factory<NetworkRequester> {
        self {
            NetworkRequester(
                encoder: self.jsonEncoder(),
                urlSession: self.urlSession()
            )
        }
    }

    func makeRecipesResponseHandler<T: Decodable>(successResponse: T.Type) -> Factory<RecipesResponseHandler<T>> {
        return self {
            RecipesResponseHandler<T>()
        }
        .cached
    }
}
