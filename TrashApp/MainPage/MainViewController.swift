//
//  MainViewController.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 13.06.2022.
//

import UIKit
import AVFoundation
import AVKit

class MainViewController: UIViewController {

    private var alreadyTap = false
    private var tapGesture: UITapGestureRecognizer!
    private var touchPoint: CGPoint?
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.greenColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var trashButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logo"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(trashAction), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()

    private lazy var photoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "circulIco"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(photoAction), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()

    private lazy var demoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "infoIco"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(demoAction), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()

    private var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCaptureStillImageOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        photoButton.layer.cornerRadius = 30
        trashButton.layer.cornerRadius = 25
        demoButton.layer.cornerRadius = 25
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSession.Preset.photo

        captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else { return }

        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }

        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)

            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
            if captureSession!.canAddOutput(stillImageOutput!) {
                captureSession!.addOutput(stillImageOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.layer.addSublayer(previewLayer!)

                captureSession!.startRunning()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let previewLayer = previewLayer else { return }
        previewLayer.frame = cameraView.frame
        alreadyTap = false
    }
}

private extension MainViewController {
    func setupConstraints() {
        view.addSubview(cameraView)
        view.addSubview(bottomView)
        bottomView.addSubview(buttonView)
        buttonView.addSubview(trashButton)
        buttonView.addSubview(photoButton)
        buttonView.addSubview(demoButton)

        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),

            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leftAnchor.constraint(equalTo: view.leftAnchor),
            cameraView.rightAnchor.constraint(equalTo: view.rightAnchor),
            cameraView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),

            buttonView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 15),
            buttonView.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 60),
            buttonView.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -60),
            buttonView.heightAnchor.constraint(equalToConstant: 60),

            photoButton.topAnchor.constraint(equalTo: buttonView.topAnchor),
            photoButton.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            photoButton.heightAnchor.constraint(equalToConstant: 60),
            photoButton.widthAnchor.constraint(equalToConstant: 60),
       
            trashButton.centerYAnchor.constraint(equalTo: photoButton.centerYAnchor),
            trashButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
            trashButton.heightAnchor.constraint(equalToConstant: 50),
            trashButton.widthAnchor.constraint(equalToConstant: 50),

            demoButton.centerYAnchor.constraint(equalTo: photoButton.centerYAnchor),
            demoButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            demoButton.heightAnchor.constraint(equalToConstant: 50),
            demoButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func takePhoto() {
        if let videoConnection = stillImageOutput!.connection(with: AVMediaType.video) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                guard
                    let sampleBuffer = sampleBuffer,
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer),
                    let dataProvider = CGDataProvider(data: imageData as CFData),
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                else { return }

                var image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                let retion = self.cameraView.frame.size.width / self.cameraView.frame.size.height

                image = self.cropToBounds(image: image, width: image.size.height * retion, height: image.size.height)
                let submitVC = SubmitPhotoViewController(image: image)
                submitVC.photoViewFrame = self.cameraView.frame
                self.navigationController?.pushViewController(submitVC, animated: true)
            })
        }
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        let retion = cameraView.frame.size.width / cameraView.frame.size.height

        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = 0
            posY = (contextSize.height - contextSize.width * retion) / 2
            cgwidth = contextSize.width
            cgheight = contextSize.width * retion
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }

    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = cameraView.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: cameraView).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: cameraView).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)

            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()

                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .continuousAutoFocus
//                    device.focusMode = .autoFocus
//                    device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
    }
    
    @objc func trashAction(sender: UIButton!) {
        if !alreadyTap {
            if let url = URL(string: "http://eco-taxi.ge/") {
                UserDefaults.standard.set(true, forKey: "comeFromMaps")
                UIApplication.shared.open(url, options: [:], completionHandler: {_ in
                    self.alreadyTap = false
                })
            }
        }
        alreadyTap = true
    }

    @objc func photoAction(sender: UIButton!) {
        if !alreadyTap {
            takePhoto()
        }
        alreadyTap = true
    }

    @objc func demoAction(sender: UIButton!) {
        if !alreadyTap {
            if let path = Bundle.main.path(forResource: "demo_video", ofType: "mp4") {
                let video = AVPlayer(url: URL(fileURLWithPath: path))
                let videoPayer = AVPlayerViewController()
                videoPayer.player = video
                
                present(videoPayer, animated: false, completion: {
                    video.play()
                })
            }
        }
        alreadyTap = true
    }
}
