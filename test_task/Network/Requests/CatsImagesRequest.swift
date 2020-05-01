//
//  CatsImagesRequest.swift
//  test_task
//
//  Created by Вадим on 30.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

public enum CatsImagesRequest: Request {
    
    case catsImages(limit: UInt, page: UInt)
    case catImage(url: String)
    // case catDetailedInfo(id: String)
    
    public var path: String {
        switch self {
        case .catsImages(_,_), .catImage(_):
            return "/images/search"
    }
    
    public var method: HTTPMethod
    
    public var parameters: RequestParams
    
    public var headers: [String : Any]?
    
    public var dataType: DataType
    
    

    
    
}
