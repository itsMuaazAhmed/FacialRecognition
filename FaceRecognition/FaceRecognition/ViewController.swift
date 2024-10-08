//
//  ViewController.swift
//  FaceRecognition
//
//  Created by Muaaz Ahmed on 07/10/2024.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController  {
    
    let camraMnger = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        camraMnger.setupCamera(for: self.view, delegate: self)
    }
    
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
   
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
            if let error = error {
                print("Face detection error: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                self.handleFaceDetectionResults(request.results as? [VNFaceObservation])
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Error in detection: \(error)")
        }
    }

    func handleFaceDetectionResults(_ observedFaces: [VNFaceObservation]?) {
        guard let faces = observedFaces else { return }
        
        // Clear previous face layers
        for sublayer in view.layer.sublayers ?? [] {
            if sublayer is CAShapeLayer {
                sublayer.removeFromSuperlayer()
            }
        }
        
        for face in faces {
            let faceBoundingBox = face.boundingBox
            
            let convertedRect = camraMnger.getPreviewLayer().layerRectConverted(fromMetadataOutputRect: faceBoundingBox)
            
            let flippedRect = CGRect(
                x: view.frame.width - convertedRect.origin.x - convertedRect.width,  // Flip horizontaly to track face corectly
                y: convertedRect.origin.y,
                width: convertedRect.width,
                height: convertedRect.height
            )
            
            // add Box
            drawFaceBoundingBox(flippedRect)
        }
    }

    func drawFaceBoundingBox(_ frameRect: CGRect) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frameRect
        shapeLayer.borderColor = UIColor.red.cgColor
        shapeLayer.borderWidth = 2
        shapeLayer.cornerRadius = 4
        view.layer.addSublayer(shapeLayer)
    }
}
