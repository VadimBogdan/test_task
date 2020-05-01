//
//  Networking.swift
//  test_task
//
//  Created by Вадим on 29.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

class CatsNetworkManager
{
    private static var decoder: JSONDecoder? = JSONDecoder()
    
    public enum NetworkError: Error {
         case server
     }
    
    public func getCats(count: UInt, page: UInt,
                        completion: @escaping (Result<[Cat],NetworkError>) -> Void) {
        do {
            var request = try CatsURLRequestBuilder.buildRequest(for: .catsJson(count: count, page: page))
            dataTask(with: &request, decoder: CatsNetworkManager.decoder, completion: completion)
        } catch {
            print(error)
        }
    }
    
    public func getImage(from url: String,
                         completion: @escaping (Result<Data,NetworkError>) -> Void) {
        do {
            var request = try CatsURLRequestBuilder.buildRequest(for: .catImage(url: url))
            dataTask(with: &request, decoder: nil, completion: completion)
        } catch {
            print(error)
        }
    }
            
    private func dataTask<T>(with request: inout URLRequest, decoder: JSONDecoder?,
                            completion: @escaping (Result<T,NetworkError>) -> Void) where T : Decodable {
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if data != nil {
                if decoder != nil {
                    completion(.success(try! decoder!.decode(T.self, from: data!)))
                } else {
                    completion(.success(data as! T))
                }
            } else {
                completion(.failure(.server))
            }
        }.resume()
    }

    /// Methods
//    public func getAll() -> Result<[Cat]?, NetworkError> {
//        guard let url = RequestUrl.images else { return .failure(.url) }
//
//        var request = URLRequest(url: url)
//        var result: Result<[Cat]?, NetworkError>!
//
//        let semaphore = DispatchSemaphore(value: 0)
//
//        request.httpMethod = "GET"
//        request.setValue(CatsNetworkManager.apiKey, forHTTPHeaderField: CatsNetworkManager.apiHeader)
//
//        URLSession.shared.dataTask(with: request) { (data, _, _) in
//            let decoder = JSONDecoder()
//
//            if data != nil {
//                result = .success(try? decoder.decode([Cat].self, from: data!))
//            } else {
//                result = .failure(.server)
//            }
//            semaphore.signal()
//        }.resume()
//
//        if semaphore.wait(timeout: .now() + timeOut) == .timedOut {
//            result = .failure(.timedOut)
//        }
//
//        return result
//    }
}
