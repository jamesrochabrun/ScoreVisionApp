//
//  Emotion.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

// EMotion Analysis

extension KairosAPI {

    /// media
    /// Create a new media object to be processed.
    
    func createMediaForAnalysis(_ image: UIImage) {
        let base64ImageData = KairosAPI.sharedInstance.convertImageToBase64String(image)
        
        let jsonBody = [
            "source": base64ImageData,
            "landmarks" : "1"
        ]
        KairosAPI.sharedInstance.request(method: "media", data: jsonBody) { data in
            // check image key exist and get data
//            if let image = ((data as? [String : AnyObject])!["images"])![0] {
//                // get root image and primary key objects
//                let attributes = (image as? [String : AnyObject])!["attributes"]
//                let transaction = (image as? [String : AnyObject])!["transaction"]
//
//                // get specific enrolled attributes
//                let gender = (attributes as? [String : AnyObject])?["gender"]!["type"]!! as! String
//                let gender_type = (gender == "F") ? "female" : "male"
//                let age = (attributes as? [String : AnyObject])!["age"]! as! Int
//                let confidence_percent = 100 * ((transaction as? [String : AnyObject])!["confidence"]! as! Double)
//
//                // display results
//                print("\n--- Enroll")
//                print("Gender: \(gender_type)")
//                print("Age: \(age)")
//                print("Confidence: \(confidence_percent)% \n")
//            }
//            else {
//                print("Error - Enroll: unable to get image data")
//            }
        }
    }
    
}
