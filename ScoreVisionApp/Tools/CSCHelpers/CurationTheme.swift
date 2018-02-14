//
//  CurationTheme.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import Photos

class CurationTheme: Equatable {
    
    let title: String
    let logString: String
    let potentialAssets: [PHAsset]
    let uniqueID: String
    
    init(title: String, logString: String, potentialAssets: [PHAsset], uniqueID: String) {
        self.title = title
        self.logString = logString
        self.potentialAssets = potentialAssets
        self.uniqueID = uniqueID
    }
    
    static func ==(lhs: CurationTheme, rhs: CurationTheme) -> Bool {
        return lhs.logString == rhs.logString
    }
    
}
