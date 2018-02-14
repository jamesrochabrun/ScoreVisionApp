//
//  PhotoListControllerDatasource.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

class PhotoListControllerDatasource: NSObject, UICollectionViewDataSource {
    
    private var images: [UIImage] = []
    private var titleObservations: [String?] = []
    
    init(images: [UIImage]) {
        self.images = images
        super.init()
    }
    
    func updateData(images: [UIImage]) {
        self.images = images
    }
    
    func updateClassifications(classifications: [String]) {
        self.titleObservations = classifications
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}






