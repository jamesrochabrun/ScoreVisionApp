//
//  PhotoListControllerDatasource.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoListControllerDatasource: NSObject, UICollectionViewDataSource {
    
    private var assets: [PHAsset] = []
    private var titleObservations: [String?] = []
    private let imageManager = PHCachingImageManager()

    init(assets: [PHAsset]) {
        self.assets = assets
        super.init()
    }
    
    func updateData(assets: [PHAsset]) {
        self.assets = assets
    }
    
    func updateClassifications(classifications: [String]) {
        self.titleObservations = classifications
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .fast
        options.isSynchronous = true
        let asset = assets[indexPath.row]
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options, resultHandler: { response, options in
            if let image = response {
                cell.photoImageView.image = image
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
}






