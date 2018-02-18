//
//  Detect.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

import UIKit

// Example - Detect
extension KairosAPI {
    
    func exampleDetect() {
        // Get base64 encoded string from filename.
        // Note: file must exist within the 'Resources' bundle path.
        
        let image = UIImage(named: "valeria.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0)
        let base64ImageData = imageData?.base64EncodedString(options:[])
        
        // setup json request params, with base64 data
        var jsonBody = [
            "image": base64ImageData
        ]

        KairosAPI.sharedInstance.request(method: "detect", data: jsonBody) { data in
            // check image key exist and get data
            
        
            print("JSONBODY \(jsonBody)")
            
//            guard let dataDict = data as? [String : AnyObject],
//                let images: [AnyObject] = dataDict["images"] as! [AnyObject],
//                let image = images[0] else {
//                    print("Error - Detect: unable to get image data")
//                    return
//            }
//
//                // get root image and primary key objects
//                let faces = ((image as? [String : AnyObject])?["faces"])![0]
//                let attributes = (faces as? [String : AnyObject])!["attributes"]
//
//                // get specific enrolled attributes
//                var gender = (attributes as? [String : AnyObject])?["gender"]!["type"]!! as! String
//                let gender_type = (gender == "F") ? "female" : "male"
//                let age = (attributes as? [String : AnyObject])!["age"]! as! Int
//                let confidence_percent = 100 * ((faces as? [String : AnyObject])!["confidence"]! as! Double)
//
//                // display results
//                print("\n--- Detect")
//                print("Gender: \(gender_type)")
//                print("Age: \(age)")
//                print("Confidence: \(confidence_percent)% \n")
//            }
        }
    }
}





