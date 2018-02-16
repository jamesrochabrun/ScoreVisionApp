//
//  PhotoCell.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/1/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

final class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var clasificationLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        clasificationLabel.text = nil
    }
}
