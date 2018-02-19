//
//  PhotoPickerManager.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//
import UIKit
import MobileCoreServices
import Photos


enum CameraSourceType {
    case cameraSource
    case librarySource
}

protocol PhotoPickerManagerDelegate: class {
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage, asset: PHAsset?)
}
class PhotoPickerManager: NSObject {
    
    private let imagePickerController = UIImagePickerController()
    private let presentingController: UIViewController
    weak var delegate: PhotoPickerManagerDelegate?
    private let imageManager = PHCachingImageManager()
    
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

        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
            })
            return
        } else if status == .authorized {
            /// only camera photo no videos
            imagePickerController.mediaTypes = [kUTTypeImage as String]
            imagePickerController.delegate = self
        }
    }
    
    /// presenting picker from source type
    func presentPhotoPicker(from source: CameraSourceType, animated: Bool) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) && source == .cameraSource  {
            imagePickerController.sourceType = .camera
            imagePickerController.cameraDevice = .front
        } else {
            imagePickerController.sourceType = .savedPhotosAlbum
        }
        presentingController.present(imagePickerController, animated: animated, completion: nil)
    }
}
extension PhotoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
//            dump(asset)
            let options = PHImageRequestOptions()
            options.version = .current
            options.resizeMode = .fast
            options.isSynchronous = true
            let bestTargetSize: CGSize = CGSize(width: 800, height: 800)
            imageManager.requestImage(for: asset, targetSize: bestTargetSize, contentMode: .aspectFit, options: options) { (response, options) in
                guard let image = response else { return }
                self.delegate?.manager(self, didPickImage: image, asset: asset)
            }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            /// getting original image for camera
            self.delegate?.manager(self, didPickImage: image, asset: nil)
        }
    }
    
    private func printAssetMetaData(_ asset: PHAsset) {
    
        var assetMetadata = """
            asset MediaType \(asset.mediaType),
        asset mediaSubtypes \(asset.mediaSubtypes),
        asset sourceType \(asset.sourceType),
        asset pixelWidth \(asset.pixelWidth),
        asset pixelHeight \(asset.pixelHeight),
        asset creationDate \(asset.creationDate),
        asset modificationDate \(asset.modificationDate),
        asset location \(asset.location),
        asset duratiom \(asset.duration),
        asset isFavorite \(asset.isFavorite),
        asset isHidden \(asset.isHidden),
        asset burstIdnetifier  \(asset.burstIdentifier),
        asset butsSelectionTypes \(asset.burstSelectionTypes),
        asset representsBurst \(asset.representsBurst)
       """
    }
}


extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
















