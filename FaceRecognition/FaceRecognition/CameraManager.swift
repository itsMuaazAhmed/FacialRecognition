//
//  CameraManager.swift
//  FaceRecognition
//
//  Created by Muaaz Ahmed on 08/10/2024.
//

import UIKit
import AVFoundation

class CameraManager: NSObject {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    func setupCamera(for view: UIView, delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.delegate = delegate
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unble to acess camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.frame
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up the camera: \(error)")
        }
    }
    
    func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return previewLayer
    }
}
