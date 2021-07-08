//
//  RegexScanner.swift
//  RegexScanner
//
//  Created by narlei on 08/07/21.
//

import AVFoundation
import CoreImage
import UIKit
import Vision

@available(iOS 13.0, *)
public class RegexScanner: UIViewController {
    // MARK: - Private Properties
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()
    
    private let device = AVCaptureDevice.default(for: .video)
    
    private var viewGuide: PartialTransparentView!
    
    private var regexRecognizedValue: String?
    private var regexString: String = ""
    
    private let videoOutput = AVCaptureVideoDataOutput()
    
    // MARK: - Public Properties
    
    public var buttonComplete: UIButton?
    
    public var buttonConfirmTitle = "Confirm"
    public var buttonConfirmBackgroundColor: UIColor = .red
    public var viewTitle = "Card scanner"
    
    // MARK: - Instance dependencies
    
    private var resultsHandler: (_ value: String?) -> Void?
    
    // MARK: - Initializers
    
    init(resultsHandler: @escaping (_ value: String?) -> Void) {
        self.resultsHandler = resultsHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    public class func getScanner(regex: String, resultsHandler: @escaping (_ value: String?) -> Void) -> UINavigationController {
        let viewScanner = RegexScanner(resultsHandler: resultsHandler)
        viewScanner.regexString = regex
        let navigation = UINavigationController(rootViewController: viewScanner)
        return navigation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        view = UIView()
    }
    
    deinit {
        stop()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        captureSession.startRunning()
        title = viewTitle
        
        let buttomItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(scanCompleted))
        buttomItem.tintColor = .white
        navigationItem.leftBarButtonItem = buttomItem
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    // MARK: - Add Views
    
    private func setupCaptureSession() {
        addCameraInput()
        addPreviewLayer()
        addVideoOutput()
        addGuideView()
    }
    
    private func addCameraInput() {
        guard let device = device else { return }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }
    
    private func addPreviewLayer() {
        view.layer.addSublayer(previewLayer)
    }
    
    private func addVideoOutput() {
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as NSString: NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }
    
    private func addGuideView() {
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = widht - (widht * 0.45)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2) - 100
        
        viewGuide = PartialTransparentView(rectsArray: [CGRect(x: viewX, y: viewY, width: widht, height: height)])
        
        view.addSubview(viewGuide)
        viewGuide.translatesAutoresizingMaskIntoConstraints = false
        viewGuide.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        viewGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        viewGuide.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        view.bringSubviewToFront(viewGuide)
        
        
        let buttonCompleteX = viewX
        let buttonCompleteY = UIScreen.main.bounds.height - 90
        buttonComplete = UIButton(frame: CGRect(x: buttonCompleteX, y: buttonCompleteY, width: 100, height: 50))
        view.addSubview(buttonComplete!)
        buttonComplete?.translatesAutoresizingMaskIntoConstraints = false
        buttonComplete?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: viewX).isActive = true
        buttonComplete?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: viewX * -1).isActive = true
        buttonComplete?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
        buttonComplete?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        buttonComplete?.setTitle(buttonConfirmTitle, for: .normal)
        buttonComplete?.backgroundColor = buttonConfirmBackgroundColor
        buttonComplete?.layer.cornerRadius = 10
        buttonComplete?.layer.masksToBounds = true
        buttonComplete?.addTarget(self, action: #selector(scanCompleted), for: .touchUpInside)
        
        view.backgroundColor = .black
    }
    
    // MARK: - Completed process
    
    @objc func scanCompleted() {
        resultsHandler(regexRecognizedValue)
        stop()
        dismiss(animated: true, completion: nil)
    }
    
    private func stop() {
        captureSession.stopRunning()
    }
    
    // MARK: - Payment detection
    
    private func handleObservedPaymentCard(in frame: CVImageBuffer) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.extractPaymentCardData(frame: frame)
        }
    }
    
    private func extractPaymentCardData(frame: CVImageBuffer) {
        let ciImage = CIImage(cvImageBuffer: frame)
        let widht = UIScreen.main.bounds.width - (UIScreen.main.bounds.width * 0.2)
        let height = widht - (widht * 0.45)
        let viewX = (UIScreen.main.bounds.width / 2) - (widht / 2)
        let viewY = (UIScreen.main.bounds.height / 2) - (height / 2) - 100 + height
        
        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
        
        // Desired output size
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // Compute scale and corrective aspect ratio
        let scale = targetSize.height / ciImage.extent.height
        let aspectRatio = targetSize.width / (ciImage.extent.width * scale)
        
        // Apply resizing
        resizeFilter.setValue(ciImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(scale, forKey: kCIInputScaleKey)
        resizeFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        let outputImage = resizeFilter.outputImage
        
        let croppedImage = outputImage!.cropped(to: CGRect(x: viewX, y: viewY, width: widht, height: height))
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])
        
        guard let texts = request.results as? [VNRecognizedTextObservation], texts.count > 0 else {
            // no text detected
            return
        }
        
        let arrayLines = texts.flatMap({ $0.topCandidates(20).map({ $0.string }) })
        
        for line in arrayLines {
            print("Trying to parse: \(line)")
            
            let trimmed = line.replacingOccurrences(of: " ", with: "")
            let values = matches(for: regexString, in: trimmed)
            if values.count > 0 {
                DispatchQueue.main.async {
                    self.tapticFeedback()
                    self.regexRecognizedValue = values.first
                    self.scanCompleted()
                }
                break
            }
            
        }
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    private func tapticFeedback() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension RegexScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        handleObservedPaymentCard(in: frame)
    }
}

// MARK: - Class PartialTransparentView

class PartialTransparentView: UIView {
    var rectsArray: [CGRect]?
    
    convenience init(rectsArray: [CGRect]) {
        self.init()
        
        self.rectsArray = rectsArray
        
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor?.setFill()
        UIRectFill(rect)
        
        guard let rectsArray = rectsArray else {
            return
        }
        
        for holeRect in rectsArray {
            let path = UIBezierPath(roundedRect: holeRect, cornerRadius: 10)
            
            let holeRectIntersection = rect.intersection(holeRect)
            
            UIRectFill(holeRectIntersection)
            
            UIColor.clear.setFill()
            UIGraphicsGetCurrentContext()?.setBlendMode(CGBlendMode.copy)
            path.fill()
        }
    }
}
