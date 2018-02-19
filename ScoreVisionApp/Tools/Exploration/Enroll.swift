//
//  Enroll.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation


// Example - Enroll
extension KairosAPI {
    
    /*
      Takes a photo, finds the faces within it, and stores the faces into a gallery you create.To enroll someone into a gallery, all you need to do is submit a JPG or PNG photo. You can submit the photo either as a publicly accessible URL, Base64 encoded photo or as a file upload.Next you need to choose an identifier for the person being enrolled. The identifier could be their name ("Bob"), something unique to your app ("ABC123xyz"), or anything meaningful for you. We call that identifier "subject_id".You also need to pick a name for the gallery we are storing your faces in. We`ve called this "gallery_name". If you had used that gallery name before, we will just add your new face to it, otherwise we will create a new gallery for you.Finally, we have some advanced options available for your use. We have set these options to sensible defaults, but sometimes there is a need to override them and we have provided that facility for you.
     */
    
    func exampleEnroll(_ file: String) {
        // setup json request params, with image url
        let base64ImageData = KairosAPI.sharedInstance.convertImageFileToBase64String(file: file)
        
        let jsonBody = [
            "image": base64ImageData,
            "gallery_name": "family",
            "subject_id": "sasha"
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


