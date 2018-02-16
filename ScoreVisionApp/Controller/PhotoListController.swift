//
//  ViewController.swift
//  ScoreVisionApp
//
//  Created by James Rochabrun on 1/31/18.
//  Copyright © 2018 James Rochabrun. All rights reserved.
//

import UIKit
import Photos
import PromiseKit
import Vision
import ImageIO
import CoreML

final class PhotoListController: UIViewController {

    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingController: self)
        manager.delegate = self
        return manager
    }()
    
    lazy var photoListControllerDatasource: PhotoListControllerDatasource = {
        return PhotoListControllerDatasource(images: [])
    }()
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var collectionClasificationLabel: UILabel!
    
    
    
    var titleTheme: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoCollectionView.dataSource = photoListControllerDatasource
    }
    
    // MARK: get Themes
    @IBAction func getSelfies(_ sender: UIButton) {
        titleTheme = "Selfies"
        KMCSCThemeBuilder.SmartAlbumType.getTheme(subType: .smartAlbumSelfPortraits, period: .fullRangeOfYear(yearsAgo: 1), justFavorites: false, sortDescriptors: [.creationDate], localytics: nil).themePromise.then { theme in
            self.updateCollection(theme)
            }.catch { error in
                print("The error is \(error)")
        }

    }
    
    @IBAction func getFavorites(_ sender: UIButton) {
        titleTheme = "Favorites"
        KMCSCThemeBuilder.SmartAlbumType.getTheme(subType: .smartAlbumFavorites, period: .ever, justFavorites: false, sortDescriptors: [.creationDate], localytics: nil).themePromise.then { theme in
            self.updateCollection(theme)
            }.catch { error in
                print("The error is \(error)")
        }
    }
    
    @IBAction func getAllPhotos(_ sender: UIButton) {
        titleTheme = "All photos"
        KMCSCThemeBuilder.SmartAlbumType.getTheme(subType: .smartAlbumUserLibrary, period: .fullRangeOfYear(yearsAgo: 1), justFavorites: false, sortDescriptors: [.creationDate], localytics: nil).themePromise.then { theme in
            self.updateCollection(theme)
            }.catch { error in
                print("The error is \(error)")
        }
    }
    
    // MARK: - Vision stuff
    // ML https://developer.apple.com/machine-learning/
    
    /// Image Classification
    
    /// 1.-  MLModelSetup  
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: MobileNet().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// 2.- Process clasifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    //  The level of confidence normalized to [0, 1] where 1 is most confident
                    
                    // The is the label or identifier of a classificaiton request. An example classification could be a string like 'cat' or 'hotdog'. The string is defined in the model that was used for the classification. Usually these are technical labels that are not localized and not meant to be used directly to be presented to an end user in the UI
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                
                print("Classification: \(descriptions.joined(separator: "\n"))")
                self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    /// 2.-  PerformRequests
    func updateClassifications(for image: UIImage) {
        classificationLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler ` (_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - camera and library picker
extension PhotoListController: PhotoPickerManagerDelegate {
    
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage) {
        // here is our image from Library or camera
        photoImageView.image = image
        manager.dismissPhotoPicker(animated: true) {
            print("dismiss")
            self.updateClassifications(for: image)
        }
    }
    
    @IBAction func launchLibrary(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.librarySource, animated: true)
    }
    
    @IBAction func launchCamera(_ sender: UIButton) {
        photoPickerManager.presentPhotoPicker(from: CameraSourceType.cameraSource, animated: true)
    }
}

// MARK: - Use this just for test result images collections
extension PhotoListController {
    
    // helper for testing
    private func updateUI(_ images: [UIImage]) {
        // update the UI
        self.countLabel.text = "\(titleTheme) count: = \(images.count)"
        self.photoListControllerDatasource.updateData(images: images)
        self.photoCollectionView.reloadData()
        // print the classifications
        images.map { self.updateClassifications(for: $0) }
    }
    
    private func updateCollection(_ theme: CurationTheme) {
        let options = PHImageRequestOptions()
        options.version = .current
        options.resizeMode = .fast
        options.isSynchronous = false
        for asset in theme.potentialAssets {
            print("KMTEST \(asset.isFavorite)")
        }
        self.createAndReturnImages(with :theme.potentialAssets, options: options).then { images in
            self.updateUI(images)
            }.catch { error in
                print("the error here is \(error)")
        }
    }
    
    private func createAndReturnImages(with assets: [PHAsset], options: PHImageRequestOptions) -> Promise<[UIImage]> {
        return Promise { fullfill, reject in
            var images: [UIImage] = []
            let _ = assets.map {
                PHImageManager.default().requestImage(for: $0, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: options, resultHandler: { response, options in
                    guard let image = response else {
                        print("Big error here")
                        reject(KMCSCError.invalidImage)
                        return
                    }
                    images.append(image)
                })
            }
            DispatchQueue.main.async {
                fullfill(images)
            }
        }
    }
}











