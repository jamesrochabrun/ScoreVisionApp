//
//  Enroll.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

/// Signup for a free Kairos API credentials at: https://developer.kairos.com/signup

// Example - Enroll
extension KairosAPI {
    
     func exampleEnroll() {
        // setup json request params, with image url
        let jsonBody = [
            "image": "https://media.kairos.com/test1.jpg",
            "gallery_name": "kairos-test",
            "subject_id": "test1"
        ]
        KairosAPI.sharedInstance.request(method: "enroll", data: jsonBody) { data in
            // check image key exist and get data
            if let image = ((data as? [String : AnyObject])!["images"])![0] {
                // get root image and primary key objects
                let attributes = (image as? [String : AnyObject])!["attributes"]
                let transaction = (image as? [String : AnyObject])!["transaction"]
                
                // get specific enrolled attributes
                let gender = (attributes as? [String : AnyObject])?["gender"]!["type"]!! as! String
                let gender_type = (gender == "F") ? "female" : "male"
                let age = (attributes as? [String : AnyObject])!["age"]! as! Int
                let confidence_percent = 100 * ((transaction as? [String : AnyObject])!["confidence"]! as! Double)
                
                // display results
                print("\n--- Enroll")
                print("Gender: \(gender_type)")
                print("Age: \(age)")
                print("Confidence: \(confidence_percent)% \n")
            }
            else {
                print("Error - Enroll: unable to get image data")
            }
        }
    }
}


