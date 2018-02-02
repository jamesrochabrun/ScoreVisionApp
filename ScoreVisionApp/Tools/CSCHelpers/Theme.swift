//
//  Theme.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/1/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import Photos

// MARK: - struct that holds data from query results

struct Theme {
    let title: String
    let potentialAssets: [PHAsset]
    let analyzedAssets: [String]
}
