//
//  CameraViewModel.swift
//  ISee
//
//  Created by Илья Кузнецов on 20.06.2024.
//

import SwiftUI
import AVFoundation
import Vision

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession!
    private var cameraOutput: AVCaptureVideoDataOutput!
    private var cameraLayer: AVCaptureVideoPreviewLayer!
    private var model: VNCoreMLModel?
    private var recognitionInterval = 0
    
    @Published var recognizedObjects: String = "Наведите камеру на объект"
    
    override init() {
        super.init()
        setupCamera()
        setupModel()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("Failed to get default camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        cameraOutput = AVCaptureVideoDataOutput()
        cameraOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        
        if captureSession.canAddOutput(cameraOutput) {
            captureSession.addOutput(cameraOutput)
        }
        
        cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraLayer.videoGravity = .resizeAspectFill
        
        captureSession.startRunning()
    }
    
    private func setupModel() {
            do {
                let config = MLModelConfiguration()
                let mobileNetV2Model = try MobileNetV2(configuration: config)
                model = try VNCoreMLModel(for: mobileNetV2Model.model)
            } catch {
                print("Failed to load model: \(error)")
                model = nil
            }
        }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if recognitionInterval < 20 {
            recognitionInterval += 1
            return
        }
        recognitionInterval = 0
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = self.model else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let error = error {
                print("Error performing request: \(error)")
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Failed to get results from request")
                return
            }
            
            
            var displayText = ""
            
            for result in results.prefix(5) {
                displayText += "\(Int(result.confidence * 100))%" + " \(ObjectDictionary.translations[result.identifier] ?? result.identifier)" + "\n"
            }
            
            //let object = results.first!
            //displayText += "\(Int(object.confidence * 100))%" + " \(ObjectDictionary.translations[object.identifier] ?? object.identifier)" + "\n"
            
            DispatchQueue.main.async {
                self.recognizedObjects = displayText
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform image request: \(error)")
        }
    }
    
    func getCameraLayer() -> AVCaptureVideoPreviewLayer {
        return cameraLayer
    }
}




