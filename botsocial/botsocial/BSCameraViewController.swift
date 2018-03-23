//
//  BSCameraViewController.swift
//  botsocial
//
//  Created by Aamir  on 19/03/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

let kCameraViewHeight:CGFloat = UIScreen.main.bounds.width
class BSCameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var imagePickerController = UIImagePickerController()
    var previewLayer: AVCaptureVideoPreviewLayer?
    let captureButton = UIButton.init(type: .system)
    let switchCameraButton = UIButton.init(type: .system)
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    let cameraView = UIView()
    let capturedImageView = UIImageView()
    var flowType = FlowType.Post
    let cancelButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(BSColorTextBlack, for: .normal)
        return button
    }()
    let backButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(BSColorTextBlack, for: .normal)
        return button
    }()
    
    let nextButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(BSColorTextBlack, for: .normal)
        return button
    }()
    
    let saveButton:UIButton = {
        let button = UIButton.init(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(BSColorTextBlack, for: .normal)
        return button
    }()
    let filterView = BSFilterView()
    let libPreviewButton:UIButton = UIButton.init(type: .system)
    let model = MobileNet()
    let objectCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.estimatedItemSize = CGSize.init(width: 1.0, height: 1.0)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    let kVisionCellReuseID = "BSVisionObjectCell"
    var visionObjects:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.imagePickerController.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(notification:)), name: kNotificationWillShowKeyboard.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: kNotificationWillHideKeyboard.name, object: nil)
        self.view.backgroundColor = UIColor.white
        
        
        self.view.addSubview(self.cancelButton)
        self.view.addSubview(self.cameraView)
        self.view.addSubview(self.capturedImageView)
        self.view.addSubview(self.filterView)
        self.view.addSubview(self.captureButton)
        self.view.addSubview(self.backButton)
        self.view.addSubview(self.nextButton)
        self.view.addSubview(self.saveButton)
        self.view.addSubview(self.libPreviewButton)
        self.view.addSubview(self.objectCollectionView)
        
        self.cameraView.addSubview(self.switchCameraButton)
        
        // Cancel button
        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        self.cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(kSidePadding)
            make.top.equalToSuperview().offset(2*kInteritemPadding)
            
        }
        
        // Camera view
        self.cameraView.backgroundColor = BSColorTextBlack
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
        
        // Next button
        self.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        self.nextButton.isHidden = true
        self.nextButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
            make.top.equalToSuperview().offset(2*kInteritemPadding)
        }
        
        //Save button
        self.saveButton.isHidden = true
        self.saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        self.saveButton.isHidden = true
        self.saveButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(kSidePadding)
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
            make.top.equalTo(self.objectCollectionView.snp.bottom).offset(0)
            make.bottom.lessThanOrEqualToSuperview()
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
        
        // LibImage Thumbnail View
        self.libPreviewButton.tintColor = UIColor.gray.withAlphaComponent(0.1)
//        self.libPreviewButton.imageView?.contentMode = .scaleAspectFill
//        self.libPreviewButton.imageView?.clipsToBounds = true
        self.libPreviewButton.layer.cornerRadius = kCornerRadius
        self.libPreviewButton.imageView?.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        
        self.libPreviewButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(2*kSidePadding)
            make.centerY.equalTo(self.cameraView.snp.bottom).offset((self.view.height() - 10 - kCameraViewHeight)/2)
            make.size.equalTo(kLibPhotoPreviewSize)
        }
        self.libPreviewButton.addTarget(self, action: #selector(didTapLibPreviewThumb(_:)), for: .touchUpInside)
        BSCommons.getLatestPhotoFromLibrary { (image) in
            if let image = image {
                self.libPreviewButton.setBackgroundImage(image, for: .normal)
            }
        }
        
        // Vision objects collection view
        self.objectCollectionView.isHidden = true
        self.objectCollectionView.delegate = self
        self.objectCollectionView.showsHorizontalScrollIndicator = false
        self.objectCollectionView.dataSource = self
        self.objectCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: kSidePadding, bottom: 0, right: kSidePadding)
        self.objectCollectionView.backgroundColor = UIColor.white
        self.objectCollectionView.register(BSVisionObjectCollectionViewCell.self, forCellWithReuseIdentifier: kVisionCellReuseID)
        self.objectCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.capturedImageView.snp.bottom).offset(kInteritemPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(kVisionObjectsListViewHeight)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopSessionIfNeeded()
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startSessionIfNeeded()
    }
    
    func startSessionIfNeeded() {
        if let session = self.captureSession, session.isRunning == false {
            session.startRunning()
        }
    }
    
    func stopSessionIfNeeded() {
        DispatchQueue(label: "prepare").async {
            if let session = self.captureSession, session.isRunning == true {
                session.stopRunning()
            }
        }
    }

    
    func createSwitchCameraButton() {
        self.switchCameraButton.setImage(#imageLiteral(resourceName: "switch_camera_icon"), for: .normal)
        self.switchCameraButton.tintColor = UIColor.white
        self.switchCameraButton.addTarget(self, action: #selector(didTapSwitchCameraButton), for: .touchUpInside)
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
            if let data = processor.photoData, var image = UIImage(data: data) {
                if self.currentCameraPosition == .front {
                    image = UIImage.init(cgImage: image.cgImage!, scale: 1.0, orientation: UIImageOrientation.leftMirrored)
                }
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
        if self.flowType == .ProfilePicture {
            self.saveButton.isHidden = false
            self.nextButton.isHidden = true
        }
        else {
            self.saveButton.isHidden = true
            self.nextButton.isHidden = false
        }
        
        self.captureButton.isHidden = true
        self.libPreviewButton.isHidden = true
        self.stopSessionIfNeeded()
        self.detectObjectsWith(image:image)
    }
    
    func detectObjectsWith(image:UIImage) {
        guard let visionModel = try? VNCoreMLModel(for: model.model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            if let observations = request.results as? [VNClassificationObservation] {
                
                // The observations appear to be sorted by confidence already, so we
                // take the top 5 and map them to an array of (String, Double) tuples.
                let top5 = observations.prefix(through: 4)
                    .map { ($0.identifier, Double($0.confidence)) }
                print(top5)
                let objects = top5.map({ (id,con) -> String in
                    return id
                })
                for item in objects {
                    
                    var explodedString = item.components(separatedBy: ",")
                    let firstObjectExploded = explodedString.first!.components(separatedBy: " ")
                    explodedString[0] = firstObjectExploded[1]
                    for i in 1..<explodedString.count {
                        explodedString[i].remove(at: explodedString[i].startIndex)
                    }
                    if explodedString.isEmpty == false {
                        self.visionObjects += explodedString
                    }
                }
                if self.visionObjects.isEmpty == false {
                    self.objectCollectionView.isHidden = false
                    self.objectCollectionView.reloadData()
                }
//                self.show(results: top5)
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: image.cgImage!)
        try? handler.perform([request])
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
    
    @objc func didTapNextButton() {
        let vc = BSShareViewController()
        vc.postImage = self.capturedImageView.image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapCancelButton() {
        self.dismiss(animated: true)
    }
    
    @objc func didTapBackButton() {
        self.saveButton.isHidden = true
        self.capturedImageView.isHidden = true
        self.capturedImageView.image = nil
        self.backButton.isHidden = true
        self.nextButton.isHidden = true
        self.cancelButton.isHidden = false
        self.libPreviewButton.isHidden = false
        self.captureButton.isHidden = false
        self.filterView.isHidden = true
        self.objectCollectionView.isHidden = true
        self.visionObjects.removeAll()
        self.startSessionIfNeeded()
    }
    
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            let inputs = captureSession.inputs
            guard let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        func switchToRearCamera() throws {
            let inputs = captureSession.inputs
            guard let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        captureSession.commitConfiguration()
    }
    
    @objc func didTapSwitchCameraButton() {
        do {
            try self.switchCameras()
        }
            
        catch {
            print(error)
        }
        
//        switch self.currentCameraPosition {
//        case .some(.front):
//            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
//
//        case .some(.rear):
//            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
//
//        case .none:
//            return
//        }
    }
    
    @objc func didTapLibPreviewThumb(_ sender:AnyObject) {
        self.showImagePicker()
    }
    @objc func didTapSaveButton() {
        self.saveButton.isEnabled = false
        if let image = self.capturedImageView.image {
            APIService.sharedInstance.updateUserProfilePicture(image: image, completion: {
                self.saveButton.isEnabled = true
                self.dismiss(animated: true)
            })
        }
        
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
    
    public enum FlowType {
        case Post
        case ProfilePicture
    }
}

extension BSCameraViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    fileprivate func showImagePicker() {
        present(imagePickerController, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        if let image = image as? UIImage {
            self.showCapturedImage(image: image)
            self.imagePickerController.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: {
            // Done cancel dismiss of image picker.
        })
    }
}

extension BSCameraViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.visionObjects.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: 130, height: 130)
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kVisionCellReuseID, for: indexPath) as! BSVisionObjectCollectionViewCell
        cell.titleLabel.text = visionObjects[indexPath.item]
        return cell
        
    }
    
}

