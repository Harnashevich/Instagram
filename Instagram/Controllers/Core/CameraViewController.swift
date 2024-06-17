//
//  CameraViewController.swift
//  Instagram
//
//  Created by Andrei Harnashevich on 2.04.24.
//

import AVFoundation
import UIKit

final class CameraViewController: UIViewController {
    
    // MARK: - UI
    
    private var output = AVCapturePhotoOutput()
    private var captureSession: AVCaptureSession?
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let cameraView = UIView()
    
    private let shutterButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.backgroundColor = nil
        return button
    }()
    
    private let photoPickerButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40)),
            for: .normal
        )
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = "Take Photo"
        view.addSubview(cameraView)
        view.addSubview(shutterButton)
        view.addSubview(photoPickerButton)
        setUpNavBar()
        checkCameraPermission()
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        photoPickerButton.addTarget(self, action: #selector(didTapPickPhoto), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        if let session = captureSession,
            !session.isRunning {
            session.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession?.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.frame = view.bounds
        previewLayer.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.width,
            height: view.width
        )
        
        let buttonSize: CGFloat = view.width/5
        shutterButton.frame = CGRect(
            x: (view.width-buttonSize)/2,
            y: view.safeAreaInsets.top + view.width + 100,
            width: buttonSize,
            height: buttonSize
        )
        shutterButton.layer.cornerRadius = buttonSize/2

        photoPickerButton.frame = CGRect(
            x: (shutterButton.left - (buttonSize/1.5))/2,
            y: shutterButton.top + ((buttonSize/1.5)/2),
            width: buttonSize/1.5,
            height: buttonSize/1.5
        )
    }
}


// MARK: - Methods

extension CameraViewController {
    
    private func setUpNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }
    
    @objc
    private func didTapClose() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc
    private func didTapTakePhoto() {
        output.capturePhoto(
            with: AVCapturePhotoSettings(),
            delegate: self
        )
    }
    
    @objc
    private func didTapPickPhoto() {
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
            // request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .authorized:
            setUpCamera()
        case .restricted, .denied:
            break
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let captureSession = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            }
            catch {
                print(error)
            }
            
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            
            // Layer
            previewLayer.session = captureSession
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
        }
    }
    
    private func showEditPhoto(image: UIImage) {
        guard let resizedImage = image.sd_resizedImage(
            with: CGSize(width: 640, height: 640),
            scaleMode: .aspectFill
        ) else {
            return
        }

        let vc = PostEditViewController(image: resizedImage)
        if #available(iOS 14.0, *) {
            vc.navigationItem.backButtonDisplayMode = .minimal
        }
        navigationController?.pushViewController(vc, animated: false)

    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            return
        }
        captureSession?.stopRunning()
        showEditPhoto(image: image)
    }
}
