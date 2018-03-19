//
//  BSCameraViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import AVFoundation

let kNotificationWillShowKeyboard = Notification(name: Notification.Name.UIKeyboardWillShow)
let kNotificationWillHideKeyboard = Notification(name: Notification.Name.UIKeyboardWillHide)

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
    let postContainerView = UIView()
    let captureImageView = UIImageView()
    let closeButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setImage(#imageLiteral(resourceName: "close_icon"), for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    let postButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Post", for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
    
    let textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.createPostContainerView()
        self.createSwitchCameraButton()
        self.createCapturePhotoButton()
        self.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.displayPreview(on: self.view)
        }
    }
    
    func createPostContainerView() {
        self.view.addSubview(self.postContainerView)
        self.postContainerView.isHidden = true
        self.postContainerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.postContainerView.addSubview(self.captureImageView)
        self.captureImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.postContainerView.addSubview(self.closeButton)
        let closeButtonSize:CGFloat = 88
        self.closeButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        self.closeButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(50)
            make.size.equalTo(closeButtonSize)
        }
        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        self.closeButton.layer.cornerRadius = closeButtonSize/2
        self.textField.attributedPlaceholder = NSAttributedString.init(string: " Say something", attributes:[NSAttributedStringKey.foregroundColor:UIColor.white])
        
        self.textField.textColor = UIColor.white
        self.textField.layer.borderColor = UIColor.white.cgColor
        self.textField.delegate = self
        self.textField.layer.borderWidth = 1
        self.textField.layer.cornerRadius = 2*kCornerRadius
        self.textField.backgroundColor = UIColor.black
        
        
        self.postContainerView.addSubview(self.textField)
        self.textField.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(64)
            make.leading.equalToSuperview().offset(kSidePadding)
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.height.equalTo(40)
        }
        
        self.postContainerView.addSubview(self.postButton)
        self.postButton.layer.cornerRadius = closeButtonSize/2
        self.postButton.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        self.postButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.centerY.equalTo(self.closeButton.snp.centerY)
            make.size.equalTo(self.closeButton.snp.size)
        }
        self.postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
    }
    
    func createSwitchCameraButton() {
        self.view.addSubview(self.switchCameraButton)
        self.switchCameraButton.setImage(#imageLiteral(resourceName: "switch_camera_icon"), for: .normal)
        self.switchCameraButton.tintColor = UIColor.white
        self.switchCameraButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(kSidePadding)
        }
    }
    
    func createCapturePhotoButton() {
        self.view.addSubview(self.captureButton)
        self.captureButton.setImage(#imageLiteral(resourceName: "capture_button"), for: .normal)
        self.captureButton.tintColor = UIColor.red
        self.captureButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(64)
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
        self.previewLayer?.frame = view.frame
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
        self.captureImageView.image = image
        self.view.bringSubview(toFront: self.postContainerView)
        self.postContainerView.isHidden = false
        
    }
    
    @objc func didTapCloseButton() {
        self.postContainerView.isHidden = true
        self.textField.text = ""
    }
    
    @objc func willShowKeyboard(notification:NSNotification) {
        guard self.view.window != nil else {return}
        
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            var tabBarHeight:CGFloat = 0.0
            if let tabbar = self.tabBarController?.tabBar {
                tabBarHeight = tabbar.height()
            }
            UIView.animate(withDuration: 1, animations: {
                self.textField.transform = self.textField.transform.translatedBy(x: 0, y: -(keyboardHeight - tabBarHeight))
            })
            
        }
    }
    
    @objc func willHideKeyboard() {
        guard self.view.window != nil else {return}
        UIView.animate(withDuration: 1, animations: {
            self.textField.transform = .identity
        })
    }
    
    @objc func didTapPostButton() {
        // Create post!
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
