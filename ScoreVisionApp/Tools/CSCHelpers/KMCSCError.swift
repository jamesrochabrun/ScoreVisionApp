//
//  KMCSCError.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

enum KMCSCError: Error {
    
    case noAlbumForSubtype(type: String)
    case noPotentialAssetsFor(theme: String)
    case noPotentialAssets
    case noRandomMoments
    case invalidImage
    
    var localizedDescription: String {
        switch self {
        case .noAlbumForSubtype(let type): return " KMCSCError - No album found for subtype \(type)"
        case .noPotentialAssetsFor(let theme): return  "KMCSCError - No Potential assests for this theme: \(theme)"
        case .noRandomMoments: return "KMCSCError no random moments founded"
        case .noPotentialAssets: return "KMCSCError no assets"
        case .invalidImage: return "Invalid Image"
        }
    }
}
