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
    
    /*
    Takes a photo and returns the facial features it finds.To detect faces, all you need to do is submit a JPG or PNG photo. You can submit the photo either as a publicly accessible URL or Base64 encoded.Finally, we have some advanced options available for your use. We have set these options to sensible defaults, but sometimes there is a need to override them and we have provided that facility for you.One additional thing to note is that the returned coordinates all begin at the top left of the photo.
     */
    
    func exampleDetect(_ file: String) {

//    func exampleDetect(_ image: UIImage) {
        
        let base64ImageData = KairosAPI.sharedInstance.convertImageFileToBase64String(file: file)
        // setup json request params, with base64 data
        let jsonBody = [
            "image": base64ImageData
        ]
        
        KairosAPI.sharedInstance.request(method: "detect", data: jsonBody) { data in
            // check image key exist and get data
            if let image = ((data as? [String : AnyObject])!["images"])! as? [AnyObject] {
                // get root image and primary key objects
                let firstImage = image[0]
                let faces = ((firstImage as? [String : AnyObject])?["faces"])! as! [[String : AnyObject]]
                let firstFaces = faces[0]
                
                let attributes = firstFaces["attributes"]
                
                // get specific enrolled attributes
                let gender = (attributes as? [String : AnyObject])?["gender"]!["type"]!! as! String
                let gender_type = (gender == "F") ? "female" : "male"
                let age = (attributes as? [String : AnyObject])!["age"]! as! Int
                let confidence_percent = 100 * (firstFaces["confidence"]! as! Double)
                
                // display results
                print("\n--- Detect")
                print("Gender: \(gender_type)")
                print("Age: \(age)")
                print("Confidence: \(confidence_percent)% \n")
            }
            else {
                print("Error - Detect: unable to get image data")
            }
        }
    }
}




