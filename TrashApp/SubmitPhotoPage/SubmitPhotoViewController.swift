//
//  SubmitPhotoViewController.swift
//  TrashApp
//
//  Created by Volodymyr Nazarkevych on 13.06.2022.
//

import UIKit
import AVFoundation

struct Dog: Codable {
    var name: String
    var owner: String
}

class SubmitPhotoViewController: UIViewController {
    var image: UIImage
    var imageString = ""
    var photoViewFrame: CGRect?
    private var squareDrawer: SquareDrawer?
    private var longPress: UILongPressGestureRecognizer!

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var photoView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private (set) var buttonStackView: UIStackView = {
        let object = UIStackView()
        object.translatesAutoresizingMaskIntoConstraints = false
        object.axis = .horizontal
        object.spacing = 100
        object.distribution = .equalSpacing
        return object
    }()

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.greenColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var correctButton: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "verify"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(correctAction), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.contentMode = .scaleAspectFill
        button.setImage(UIImage(named: "cancel"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()

    private lazy var alertView: AlertTags = {
        let view = AlertTags()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cancelHandler = {
            self.alertView.isHidden = true
        }
 
        view.chooseTagHandler = { [weak self] tag in
            guard let self = self else { return }
            self.squareDrawer?.addTag(tag: tag)
            self.alertView.isHidden = true
            
            self.saveJpg()
            self.saveJSON(tag)
            
            let alert = UIAlertController(title: "Success", message: "Task completed", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
        return view
    }()
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {

        setupConstraints()
        setupView()
        squareDrawer = SquareDrawer(videoView: imageView, center: view.center, photoViewFrame: photoViewFrame ?? view.frame)
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDidPress(recognizer:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0
        photoView.addGestureRecognizer(longPress)
        
        imageString = image.pngData()?.base64EncodedString() ?? ""
    }
}

private extension SubmitPhotoViewController {
    func saveJpg() {
        if let data = image.jpegData(compressionQuality: 0.5) {
            let filename = getDocumentsDirectory().appendingPathComponent("photo_\(gatDate()).jpg")
            try? data.write(to: filename)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveJSON(_ tag: String) {
        let stringPatch = getDocumentsDirectory().absoluteString
        let pointA = squareDrawer?.getPointA()
        let center = squareDrawer?.getCenter()
        let proportion = image.size.height / photoView.frame.size.height

//        let shape = Shape(label: "2 hdpe", points: [[pointA!.x*proportion, pointA!.y*proportion], [center!.x*proportion, center!.y*proportion]], shape_type: tag)
//        let jsonModel = JSONModel(version: "4.5.12", flags: Flags(), shapes: [shape], imagePath: stringPatch, imageData: imageString, imageHeight: Int(image.size.height), imageWidth: Int(image.size.width))

        
        let testObject = """
{
  "version": "4.5.12",
  "flags": {},
  "shapes": [
    {
       "label": "2 hdpe",
       "points": [
         [
           \(pointA!.x*proportion),
           \(pointA!.y*proportion)
         ],
         [
           \(center!.x*proportion),
           \(center!.y*proportion)
         ]
        ],
        "group_id": null,
        "shape_type": \(tag),
        "flags": {}
      }
    ],
    "imagePath": \(stringPatch),
    "imageData": \(imageString),
    "imageHeight": \(Int(image.size.height)),
    "imageWidth": \(Int(image.size.width))
}
"""
//        let jsonEncoder = JSONEncoder()
//        jsonEncoder.outputFormatting = .sortedKeys
//        let jsonData = try! jsonEncoder.encode(jsonModel)
//        let json = String(data: jsonData, encoding: String.Encoding.utf8)
//        guard let string = json?.data(using: .utf8)!.prettyPrintedJSONString! else { return }
        let patch = getDocumentsDirectory().appendingPathComponent("photo_\(gatDate()).json")
        try! testObject.write(to: patch, atomically: true, encoding: .utf8)
    }
    
    func gatDate() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return dateFormatterGet.string(from: Date())
    }
    func setupView() {
        alertView.isHidden = true
    }

    func setupConstraints() {
        view.addSubview(photoView)
        photoView.addSubview(imageView)
        view.addSubview(bottomView)
        bottomView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(correctButton)
        view.addSubview(alertView)

        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 100),

            photoView.topAnchor.constraint(equalTo: view.topAnchor),
            photoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            photoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            photoView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),

            imageView.topAnchor.constraint(equalTo: photoView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: photoView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: photoView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: photoView.rightAnchor),

            buttonStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 15),
            buttonStackView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.widthAnchor.constraint(equalToConstant: 50),

            correctButton.heightAnchor.constraint(equalToConstant: 50),
            correctButton.widthAnchor.constraint(equalToConstant: 50),
            
            alertView.leftAnchor.constraint(equalTo: view.leftAnchor),
            alertView.rightAnchor.constraint(equalTo: view.rightAnchor),
            alertView.topAnchor.constraint(equalTo: view.topAnchor),
            alertView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc func correctAction(sender: UIButton!) {
        alertView.isHidden = false
    }

    @objc func cancelAction(sender: UIButton!) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func longPressDidPress(recognizer: UILongPressGestureRecognizer) {
        guard longPress != nil else { return }
        squareDrawer?.handleLongPressGesture(longPress: longPress)
    }
}

extension SubmitPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
