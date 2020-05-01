//
//  Cat.swift
//  test_task
//
//  Created by Вадим on 29.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import Foundation

struct Cat: Decodable, Equatable
{
    let id: String?
    let url: String?
    
    static func == (lhs: Cat, rhs: Cat) -> Bool {
        return lhs.id == rhs.id || lhs.url == rhs.url 
    }
}
