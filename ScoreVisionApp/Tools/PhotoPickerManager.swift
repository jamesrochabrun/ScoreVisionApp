//
//  PhotoPickerManager.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//
import UIKit
import MobileCoreServices

enum CameraSourceType {
    case cameraSource
    case librarySource
}

protocol PhotoPickerManagerDelegate: class {
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage)
}
class PhotoPickerManager: NSObject {
    
    private let imagePickerController = UIImagePickerController()
    private let presentingController: UIViewController
    weak var delegate: PhotoPickerManagerDelegate?
    
    init(presentingController: UIViewController) {
        self.presentingController = presentingController
        super.init()
        configure()
    }
    
    /// dismissing picker
    func dismissPhotoPicker(animated: Bool, completion: (() -> Void)?) {
        imagePickerController.dismiss(animated: animated, completion: completion)
    }
    
    /// configure picker
    private func configure() {

        /// only camera photo no videos
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        imagePickerController.delegate = self
    }
    
    /// presenting picker from source type
    func presentPhotoPicker(from source: CameraSourceType, animated: Bool) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) && source == .cameraSource  {
            imagePickerController.sourceType = .camera
            imagePickerController.cameraDevice = .front
        } else {
            imagePickerController.sourceType = .photoLibrary
        }
        presentingController.present(imagePickerController, animated: animated, completion: nil)
    }
}
extension PhotoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        /// getting original image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        self.delegate?.manager(self, didPickImage: image)
    }
}
