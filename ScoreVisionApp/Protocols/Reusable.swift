//
//  Reusable.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/1/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

// Protocol oriented programming, extending functionality for base classes

/// 1 Define an empty protocol to avoid forced usage of functionality
protocol Reusable {}

/// 2 Protocols extension can hold "optional" functionality
/// This protocol will help to avoid usage of reuse identifiers as string literals and on storyboards
extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

/// 3 extend the base class to apply conformance
extension UITableViewCell: Reusable {}
extension UICollectionViewCell: Reusable {}

extension UIViewController: Reusable {}
/// 4 extend the base class and use generics
extension UITableView {
    
    func register<T: UITableViewCell>(_ :T.Type)  {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T  {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            return T()
        }
        return cell
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ :T.Type)  {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T  {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            return T()
        }
        return cell
    }
}

extension UIStoryboard {
    func instantiateViewContoller<T: UIViewController>(_ :T.Type) {
        self.instantiateViewController(withIdentifier: T.reuseIdentifier)
    }
}
