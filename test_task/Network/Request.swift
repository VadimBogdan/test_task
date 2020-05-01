//
//  Request.swift
//  test_task
//
//  Created by Вадим on 30.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

public enum DataType {
    case JSON
}

public protocol Request {
    
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: RequestParams { get }
    var headers: [String:Any]? { get }
    var dataType: DataType { get }
    
}

public enum HTTPMethod: String {
    case get = "GET"
}

public enum RequestParams {
    case body(_: [String: Any]?)
    case url(_: [String: Any]?)
}
