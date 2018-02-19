//
//  Recognize.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 2/18/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import Foundation

// Example - Recognize

extension KairosAPI {
    
    /*
     Takes a photo, finds the faces within it, and tries to match them against the faces you have already enrolled into a gallery.To match someone to a face enrolled in your gallery, all you need to do is submit a JPG or PNG photo. You can submit the photo either as a publicly accessible URL, Base64 encoded photo or as a file upload.Next, specify which gallery we should search against for matches. This is the same name you used previously during the /enroll calls to create the gallery.We have the concept of a matching threshold, which by default is set at 60%. If the face you submit is 60% similar to one or more faces in your gallery we will return that as a list of potential candidates and how closely they match. If no one falls in that range we will return no matches.Depending on your usage, you may want to adjust the threshold lower or higher to return more or less potential candidates respectively.Finally, we have some advanced options available for your use. We have set these options to sensible defaults, but sometimes there is a need to override them and we have provided that facility for you.
 */
    
    func exampleRecognize(_ file : String) {
        
        let base64ImageData = KairosAPI.sharedInstance.convertImageFileToBase64String(file: file)
        let jsonBody = [
            "image": base64ImageData,
            "gallery_name": "family",
            "threshold" : "0.63" // accuracy specified in my request
//            "max_num_results" : "0.2"
        ]
        
        KairosAPI.sharedInstance.request(method: "recognize",  data: jsonBody) { data in
            
            if let images = ((data as? [String : AnyObject])!["images"]) {

                print("IMAGEs \(images)")
            }
            
        }
    }
    
    
    
}
