//
//  ViewController.swift
//  TextRecognition
//
//  Created by YACHIEH LAI on 12/27/22.
//
// Starting from ChatGPT code!

// From ChatGPT:
// This code uses the AVCaptureSession and AVCaptureVideoDataOutput classes to capture images from the camera,
// and the VNRecognizeTextRequest class from the Vision framework to perform text recognition on the images.
// The TextRecognitionView struct is a UIViewControllerRepresentable that wraps the TextRecognitionViewController
// class and allows it to be used in a SwiftUI app. The recognizedText binding is used to update the recognized
// text as it is recognized.

import SwiftUI
import AVFoundation
import Vision

struct TextRecognitionView: UIViewControllerRepresentable {
    @Binding var recognizedText: String

    func makeUIViewController(context: Context) -> TextRecognitionViewController {
        return TextRecognitionViewController(recognizedText: $recognizedText)
    }

    func updateUIViewController(_ uiViewController: TextRecognitionViewController, context: Context) {
        // Update the recognized text binding as necessary
    }
}

class TextRecognitionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var textRecognitionRequest = VNRecognizeTextRequest()
    @Binding var recognizedText: String

    init(recognizedText: Binding<String>) {
        _recognizedText = recognizedText
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the text recognition request
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = true
        
        // Set up the capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)
        } catch {
            print("Error adding back camera input: \(error)")
            return
        }
        
        // Set up the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        captureSession.addOutput(videoOutput)
        
        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Start the capture session
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Get the pixel buffer for the image
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Create a request handler for the text recognition request
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options:[:])
        
        // Perform the text recognition request
        do {
            try requestHandler.perform([textRecognitionRequest])
        } catch {
            print("Error performing text recognition request: \(error)")
            return
        }
        
        // Get the recognized text from the request's results
        guard let results = textRecognitionRequest.results, !results.isEmpty else {
            return
        }
        
        if let observation = results.first as? VNRecognizedTextObservation {
            // Do something with the recognized text, such as update the recognized text binding or display it on the screen
            let topCandidate = observation.topCandidates(1).first
            if let recognizedText = topCandidate?.string {
                self.recognizedText = recognizedText
            }
        }
    }
}

