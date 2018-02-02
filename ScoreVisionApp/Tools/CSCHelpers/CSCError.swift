//
//  Result.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/1/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

enum CSCError: Error {
    case noImages
    case invalidImage
    
    var localizedDescription: String {
        switch self {
        case .noImages: return "No images"
        case .invalidImage: return "Invalid image"
        }
    }
}
