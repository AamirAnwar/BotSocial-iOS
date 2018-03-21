//
//  BSCameraViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import AVFoundation
import Sharaku


let kCameraViewHeight:CGFloat = UIScreen.main.bounds.width
class BSCameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    let captureButton = UIButton.init(type: .system)
    let switchCameraButton = UIButton.init(type: .system)
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    let cameraView = UIView()
    let capturedImageView = UIImageView()
    let cancelButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    let backButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    let filterView = BSFilterView()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.view.backgroundColor = UIColor.white
        
        
        self.view.addSubview(self.cancelButton)
        self.view.addSubview(self.cameraView)
        self.view.addSubview(self.capturedImageView)
        self.view.addSubview(self.filterView)
        self.view.addSubview(self.captureButton)
        self.view.addSubview(self.backButton)
        
        self.cameraView.addSubview(self.switchCameraButton)
        
        // Cancel button
        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        self.cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(2*kInteritemPadding)
            
        }
        
        // Camera view
        self.cameraView.backgroundColor = UIColor.black
        self.cameraView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.cancelButton.snp.bottom).offset(kInteritemPadding)
            make.height.equalTo(kCameraViewHeight)
        }
        
        // Captured Image View
        self.capturedImageView.isHidden = true
        self.capturedImageView.contentMode = .scaleAspectFill
        self.capturedImageView.clipsToBounds = true
        self.capturedImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(kInteritemPadding)
            make.height.equalTo(kCameraViewHeight)
        }
        
        
        // Back button
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        self.backButton.isHidden = true
        self.backButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(2*kInteritemPadding)
        }
        
        self.createSwitchCameraButton()
        self.createCapturePhotoButton()
        self.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.displayPreview(on: self.cameraView)
        }
        
        // Filter View
        self.filterView.isHidden = true
        self.filterView.snp.makeConstraints { (make) in
            make.top.equalTo(self.capturedImageView.snp.bottom).offset(kInteritemPadding)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        let rightSwipe = UISwipeGestureRecognizer.init(target: self.filterView, action: #selector(self.filterView.imageViewDidSwipeRight))
        rightSwipe.direction = .right
        self.capturedImageView.addGestureRecognizer(rightSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer.init(target: self.filterView, action: #selector(self.filterView.imageViewDidSwipeLeft))
        leftSwipe.direction = .left
        self.capturedImageView.isUserInteractionEnabled = true
        self.capturedImageView.addGestureRecognizer(leftSwipe)
        
    }

    
    func createSwitchCameraButton() {
        self.switchCameraButton.setImage(#imageLiteral(resourceName: "switch_camera_icon"), for: .normal)
        self.switchCameraButton.tintColor = UIColor.white
        self.switchCameraButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(kInteritemPadding)
            make.leading.equalToSuperview().offset(kSidePadding)
        }
    }
    
    func createCapturePhotoButton() {
        self.captureButton.setImage(#imageLiteral(resourceName: "capture_button"), for: .normal)
        self.captureButton.tintColor = UIColor.red
        self.captureButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.cameraView.snp.bottom).offset((self.view.height() - 10 - kCameraViewHeight)/2)
        }
        self.captureButton.addTarget(self, action: #selector(didTapCapturePhoto), for: .touchUpInside)
        
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {self.captureSession = AVCaptureSession() }
        func configureCaptureDevices() throws {
            //1
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = (session.devices.flatMap { $0 })
            if cameras.isEmpty {
                throw CameraControllerError.noCamerasAvailable
            }
            
            //2
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
            
        }
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            self.photoOutput!.isHighResolutionCaptureEnabled = true
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.bounds
    }
    
    @objc func didTapCapturePhoto() {
        guard let photoOutput = self.photoOutput else {
            return
        }
        var photoSettings = AVCapturePhotoSettings()
        // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
        if  photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
//        photoSettings.flashMode = .auto
        photoSettings.isHighResolutionPhotoEnabled = true
        if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }
        let photoCaptureProcessor = PhotoCaptureProcessor.init(with: photoSettings, willCapturePhotoAnimation: {
            DispatchQueue.main.async {
                self.previewLayer?.opacity = 0
                UIView.animate(withDuration: 0.24, animations: {
                    self.previewLayer?.opacity = 1
                })
            }
        }) { (processor) in
            DispatchQueue(label: "capture_photo").async {
                self.inProgressPhotoCaptureDelegates[processor.requestedPhotoSettings.uniqueID] = nil
            }
            if let data = processor.photoData, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.showCapturedImage(image: image)
                }
            }
            
        }
        self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
    }
    
    func showCapturedImage(image:UIImage) {
        self.capturedImageView.image = image
        self.filterView.capturedImageView = self.capturedImageView
        self.filterView.isHidden = false
        self.capturedImageView.isHidden = false
        self.cancelButton.isHidden = true
        self.backButton.isHidden = false
        self.captureButton.isHidden = true
    }
    
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            var tabBarHeight:CGFloat = 0.0
            if let tabbar = self.tabBarController?.tabBar {
                tabBarHeight = tabbar.height()
            }
            
            
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        UIView.animate(withDuration: 1, animations: {
            
        })
    }
    
    @objc func didTapPostButton() {
        // Create post!
    }
    
    @objc func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc func didTapBackButton() {
        self.capturedImageView.isHidden = true
        self.capturedImageView.image = nil
        self.backButton.isHidden = true
        self.cancelButton.isHidden = false
        self.captureButton.isHidden = false
        self.filterView.isHidden = true
    }
    
    @objc func didTapApplyFilters() {
//        let imageToBeFiltered = UIImage(named: "targetImage")
        let vc = SHViewController(image: self.capturedImageView.image!)
//        vc.delegate = self
        self.present(vc, animated:true, completion: nil)
    }
}

extension BSCameraViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension BSCameraViewController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}


