//
//  CatDetailedViewController.swift
//  test_task
//
//  Created by Вадим on 01.05.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class CatDetailedViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    public var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
