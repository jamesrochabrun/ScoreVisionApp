//
//  File.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

// Example - Verify
extension KairosAPI {
    
    /*
     Takes a photo, finds the face within it, and tries to compare it against a face you have already enrolled into a gallery.To verify a face that you have enrolled in your gallery, all you need to do is submit a JPG or PNG photo. You can submit the photo either as a publicly accessible URL, Base64 encoded photo or as a file upload.Next, specify which gallery and subject ID we should search against to compare. These are the same names you used previously during the /enroll calls to create the gallery.Note: As long as the request is able to perform a match then you will receive a status of "success". You should use the "confidence" value to determine whether the comparison is valid for your application. We find that confidence values in excess of 60% are almost always of the same person.
     */
    
    func exampleVerify(_ file: String) {
        
        let base64ImageData = KairosAPI.sharedInstance.convertImageFileToBase64String(file: file)
        
        let jsonBody = [
            "image": base64ImageData,
            "gallery_name": "family",
            "subject_id": "sasha"
        ]
        
        KairosAPI.sharedInstance.request(method: "verify", data: jsonBody) { data in
            if let image = ((data as? [String : AnyObject])!["images"])![0] {
                // get root image and primary key objects
                
                let transaction = (image as? [String : AnyObject])!["transaction"]
                let confidence = transaction!["confidence"] as! Double

                let confidence_percent = 100 * confidence
                let status = transaction!["status"] as! String
//                // display results
                print("\n--- Verify")
                print("Confidence: \(confidence_percent)% \n")
                print("Status: \(status)")
            }
            else {
                print("Error - Enroll: unable to get image data")
            }
        }
    }
}
