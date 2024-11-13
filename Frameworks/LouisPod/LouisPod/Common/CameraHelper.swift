//
//  CameraHelper.swift
//  BaseProject
//
//  Created by nguyen.viet.luy on 20/01/2021.
//

import MobileCoreServices
import UIKit

open class CameraHelper: NSObject {
    static public let shared = CameraHelper()
    private var completion: ((UIImage) -> Void)?
    
    private var imagePicker = UIImagePickerController()
    private let isPhotoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    private let isSavedPhotoAlbumAvailable = UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
    private let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    private let isRearCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(.rear)
    private let isFrontCameraAvailable = UIImagePickerController.isCameraDeviceAvailable(.front)
    private let sourceTypeCamera = UIImagePickerController.SourceType.camera
    private let rearCamera = UIImagePickerController.CameraDevice.rear
    private let frontCamera = UIImagePickerController.CameraDevice.front
 
}

// MARK: - Functions
extension CameraHelper {
    public func optionImage(_ onVC: UIViewController, completion: ((UIImage) -> Void)?) {
        let alert = UIAlertController(title: "Select from:",
                                      message: nil,
                                      preferredStyle: .actionSheet).then {
            $0.addAction(UIAlertAction(title: "Take a Photo",
                                       style: .default,
                                       handler: { [unowned self] _ in
                getCameraOn(onVC, canEdit: false)
            }))
            $0.addAction(UIAlertAction(title: "Camera Roll",
                                       style: .default,
                                       handler: { [unowned self] _ in
                getPhotoLibraryOn(onVC, mediaTypes: [.image], canEdit: false)
            }))
            $0.addAction(UIAlertAction(title: "Cancel",
                                       style: .cancel,
                                       handler: nil))
        }
        onVC.presentAlertVC(alert)
        self.completion = completion
    }
    
    private func getPhotoLibraryOn(_ onVC: UIViewController,
                                  mediaTypes: [MediaType],
                                  canEdit: Bool = false) {
        guard isPhotoLibraryAvailable && isSavedPhotoAlbumAvailable else { return }
        
        imagePicker = UIImagePickerController()
        let sourceType: UIImagePickerController.SourceType = isPhotoLibraryAvailable
        ? .photoLibrary
        : .savedPhotosAlbum
        imagePicker.sourceType = sourceType
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: sourceType) {
            let mediaTypesValid: [String] = mediaTypes
                .filter { availableTypes.contains($0.value) }
                .map { $0.value }
            imagePicker.mediaTypes = mediaTypesValid
            imagePicker.allowsEditing = canEdit
        }
        imagePicker.navigationBar.tintColor = .blue
        imagePicker.navigationBar.barStyle = .default
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        onVC.present(imagePicker, animated: true, completion: nil)
    }
    
    private func getCameraOn(_ onVC: UIViewController, canEdit: Bool) {
        guard isCameraAvailable else { return }
        
        imagePicker = UIImagePickerController()
        let mediaTypeImage = MediaType.image.value
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if availableTypes.contains(mediaTypeImage) {
                imagePicker.mediaTypes = [mediaTypeImage]
                imagePicker.sourceType = sourceTypeCamera
            }
        }
        
        if isRearCameraAvailable {
            imagePicker.cameraDevice = rearCamera
        } else if isFrontCameraAvailable {
            imagePicker.cameraDevice = frontCamera
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .overFullScreen
        onVC.present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CameraHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                let imageToDisplay = pickedImage.fixImageOrientation()
                self.completion?(imageToDisplay)
            })
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Enums
extension CameraHelper {
    public enum MediaType: String {
        case image
        case video
        var value: String {
            switch self {
            case .image:
                return kUTTypeImage as String
            case .video:
                return kUTTypeMovie as String
            }
        }
    }
}

extension UIImage {
    public func fixImageOrientation() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
