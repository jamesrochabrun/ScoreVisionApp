//
//  ViewController.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit
import PromiseKit
import Photos

final class PhotoListController: UIViewController {

    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingController: self)
        manager.delegate = self
        return manager
    }()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - camera and library picker
extension PhotoListController: PhotoPickerManagerDelegate {
    
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage, asset: PHAsset?) {
        // here is our image from Library or camera
        photoImageView.image = image
        self.classificationLabel.text = "Analaysing..."

        // KairosAPI.sharedInstance.exampleDetect(image)
        
        // do exampleVerify or exampleDetect
        guard let asset = asset else { return }
        asset.getURL(completionHandler: { url in
            KairosAPI.sharedInstance.exampleDetect(String(describing: url!)).then { text in
                self.classificationLabel.text = text
                }.catch(execute: { err in
                    print("ERROR \(err)")
                })
        })
        manager.dismissPhotoPicker(animated: true, completion: nil)
    }
    
    @IBAction func launchLibrary(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.librarySource, animated: true)
    }
    
    @IBAction func launchCamera(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.cameraSource, animated: true)
    }
}














