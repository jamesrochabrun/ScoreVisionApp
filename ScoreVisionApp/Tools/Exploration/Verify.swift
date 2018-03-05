//
//  File.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation
import PromiseKit

// Example - Verify
extension KairosAPI {
    
    /*
     Takes a photo, finds the face within it, and tries to compare it against a face you have already enrolled into a gallery.To verify a face that you have enrolled in your gallery, all you need to do is submit a JPG or PNG photo. You can submit the photo either as a publicly accessible URL, Base64 encoded photo or as a file upload.Next, specify which gallery and subject ID we should search against to compare. These are the same names you used previously during the /enroll calls to create the gallery.Note: As long as the request is able to perform a match then you will receive a status of "success". You should use the "confidence" value to determine whether the comparison is valid for your application. We find that confidence values in excess of 60% are almost always of the same person.
     */
    
    func exampleVerify(_ image: UIImage) -> Promise<(String, Bool)> {
        
        let base64ImageData = KairosAPI.sharedInstance.convertImageToBase64String(image)
        
        let jsonBody = [
            "image": base64ImageData,
            "gallery_name": "family",
            "subject_id": "sasha"
        ]
        
        return Promise { fullfill, reject in
            
            KairosAPI.sharedInstance.request(method: "verify", data: jsonBody) { data in
                
                if let dataDict = data as? [String: AnyObject], let imagesArray = dataDict["images"] as? [[String : AnyObject]],
                    let image = imagesArray.first {
                
                    // get root image and primary key objects
                    
                    let transaction = image["transaction"]
                    let confidence = transaction!["confidence"] as! Double
                    let subjectID = transaction!["subject_id"] as! String
                    
                    
                    let confidence_percent = 100 * confidence
                    
                    let isSubject = confidence_percent >= 50 ? "Yeap this is \(subjectID)" : "This is not \(subjectID)"
                    let isSubjectBoolean = confidence_percent >= 50 ? true : false
                    let status = transaction!["status"] as! String
                    //                // display results
                    
                    let apiSuccess = "API request Verify \n Confidence: \(confidence_percent)% \n \(isSubject)\n Request Status: \(status)"
                    print("\n--- Verify")
                    print("Confidence: \(confidence_percent)% \n")
                    print("Status: \(status)")
                    DispatchQueue.main.async {
                        fullfill((apiSuccess, isSubjectBoolean))
                    }
                }
                else {
                    print("Error - Enroll: unable to get image data")
                    reject(NSError.cancelledError())
                }
            }
        }
    }
}





