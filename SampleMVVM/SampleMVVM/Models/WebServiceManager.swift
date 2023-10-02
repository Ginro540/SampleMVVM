//
//  WebServiceManager.swift
//  SampleMVVM
//
//  Created by 古賀貴伍社用 on 2023/09/28.
//

import Combine
import UIKit

class WebServiceManager: NSObject {
    
    static let shared = WebServiceManager()
    
    private var cancellable = Set<AnyCancellable>()
    
    func getData<T: Decodable>(endpoint: String, id: Int? = nil, type: T.Type) -> Future<T, Error> {
        
        return Future<T, Error> { [weak self] promise in
            guard let self = self, let url = URL(string: endpoint) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            print("URL is \(url.absoluteString)")
            
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap {(data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { complete in
                    if case let .failure(error) = complete {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as NetworkError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkError.unknown))
                        }
                    }
                }, receiveValue: { data in
                    print(data)
                    promise(.success(data))
                }).store(in: &self.cancellable)
        }
    }
}
