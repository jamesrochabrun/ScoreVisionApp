//
//  KMCSCSortDescriptorProvider.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/13/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

// MARK: - protocol
protocol KMCSCSortDescriptorProvider {
    var sortDescriptor: NSSortDescriptor { get }
}

enum SortProvider {
    case creationDate /// when adding a new case here we also need to add one sortdescriptor for this case
}

// MARK: - extension for SortDescriptorProvider conformance, returns a sortDescriptor
extension SortProvider: KMCSCSortDescriptorProvider {
    
    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .creationDate:
            return NSSortDescriptor(key: "creationDate", ascending: true)
        }
    }
}
