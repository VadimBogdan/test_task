//
//  CatsURLComposer.swift
//  test_task
//
//  Created by Вадим on 30.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct CatsURLRequestBuilder
{
    private struct CatsUrl
    {
        public static let catsImagesBase = URLComponents(string: "https://api.thecatapi.com/v1/images/search")!
    }
    
    public enum CatsURLRequestBuilderError: CustomStringConvertible, Error {
        case badURL(url: String)
        
        public var description: String {
            switch self {
            case let .badURL(url):
                return "CatsURLRequestBuilder.makeURL() -> failed to make url. \(url)"
            }
        }
    }
    
    public enum CatsRequestType {
        case catsJson(count: UInt, page: UInt)
        case catImage(url: String)
        
        var headers: [String:String] {
            switch self {
            case.catsJson,.catImage:
                return [Environment.apiKey:Environment.apiHeader]
            }
        }
        
        var httpMethod: String {
            switch self {
            case .catsJson,.catImage:
                return "GET"
            }
        }
        
        var order: String {
            return "asc"
        }
    }
    
    public static func buildRequest(for requestType: CatsRequestType) throws -> URLRequest {
        let url = try makeURL(for: requestType)
        var request = URLRequest(url: url)
        request.httpMethod = requestType.httpMethod
        requestType.headers.forEach { request.addValue($0.key, forHTTPHeaderField: $0.value) }
        return request
    }
    
    private static func makeURL(for requestType: CatsRequestType) throws -> URL {
        switch requestType {
        case.catsJson(let count, let page):
            var urlComponents = CatsUrl.catsImagesBase
            let countQuery = URLQueryItem(name: "limit", value: "\(count)")
            let pageQuery = URLQueryItem(name: "page", value: "\(page)")
            let orderQuery = URLQueryItem(name: "order", value: "\(requestType.order)")
            urlComponents.queryItems = [countQuery,pageQuery,orderQuery]
            return urlComponents.url!
        case let .catImage(url):
            guard let _url = URL(string: url) else { throw CatsURLRequestBuilderError.badURL(url: url) }
            return _url
        }
    }
}
