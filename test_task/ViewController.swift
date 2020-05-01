//
//  ViewController.swift
//  test_task
//
//  Created by Вадим on 29.04.2020.
//  Copyright © 2020 Vadym Bogdan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var catsCache: CatsCache?
    private var networkManager = CatsNetworkManager()
    
    private(set) var count: UInt = 26
    private(set) var page: UInt = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUp()
    }
    
    private func startUp() {
        let group = DispatchGroup()
        group.enter()
        getCats(in: group)
        getCatsImages(in: group)
    }
    
    private func getCats(in group: DispatchGroup) {
        DispatchQueue.global().async { [unowned self] in
            self.networkManager.getCats(count: self.count, page: self.page) { [unowned self] result in
                switch result {
                  case let .success(cats):
                    if self.catsCache == nil {
                        self.catsCache = CatsCache(cats: cats.filter { $0.url != nil && $0.id != nil },
                                                   networkManager: self.networkManager)
                    } else {
                        self.catsCache?.addCats(cats.filter { $0.url != nil && $0.id != nil })
                    }
                  case let .failure(error):
                    print("(\(error))")
                }
                group.leave()
            }
        }
    }
    
    private func getCatsImages(in mainGroup: DispatchGroup) {
        DispatchQueue.global().async { [unowned self] in
            mainGroup.wait()
            let group = DispatchGroup()
            
            if self.catsCache != nil {
                for catIndex in Int(self.page)..<self.catsCache!.cats.count {
                    group.enter()
                    let url = self.catsCache!.cats[catIndex].url!
                    self.networkManager.getImage(from: url) { [unowned self] result in
                        switch result {
                          case let .success(catImageData):
                            if let image = UIImage(data: catImageData) {
                                self.catsCache?.insertCatImage(image, for: url)
                            } else {
                                self.catsCache?.removeCatImage(at: catIndex)
                            }
                          case let .failure(error):
                            print("(\(error))")
                        }
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                self.collectionView.reloadData()
                if let newPage = self.catsCache?.cats.count {
                    self.page += UInt(newPage)
                }
            }
        }
    }
}

@available(iOS 12.0, *)
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catsCache?.cats.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catCell", for: indexPath) as! CatCollectionViewCell
        if catsCache != nil {
            cell.catImageView.image = resize(image: catsCache![indexPath.row], for: cell.bounds.size)
            cell.layer.cornerRadius = 10.0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CatDetailedViewController") as? CatDetailedViewController
        if let cell = collectionView.cellForItem(at: indexPath) as? CatCollectionViewCell, let image = cell.catImageView.image {
            vc?.image = image
        }
        navigationController?.pushViewController(vc!, animated: true)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = collectionView.bounds
        return CGSize(width: bounds.width / 3  - 10.0, height: bounds.height / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension ViewController {
    private func resize(image: UIImage?, for size: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
