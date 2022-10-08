//
//  CameraViewController.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/18/22.
//

import UIKit
import SwiftUI
import Vision
import AVKit

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
        
    private(set) var cameraController = CameraController()
    private var previewView: UIView!
    private var bufferOrientation: CGImagePropertyOrientation = .leftMirrored
    private var frameCounter = 0
    
    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1

        return handPoseRequest
    }()
    
    var gestureProcessor: HandGestureModel?
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCamera()
    }
    
    override func viewDidLayoutSubviews() {
        if let orientation = view.window?.windowScene?.interfaceOrientation {
            previewView.frame = view.frame
            cameraController.previewLayer?.frame = previewView.frame

            // print("Orientation: ", orientation.rawValue)

            switch orientation {
            case .portrait:
                self.cameraController.previewLayer?.connection?.videoOrientation = .portrait
                self.bufferOrientation = .leftMirrored
            case .landscapeLeft:
                self.cameraController.previewLayer?.connection?.videoOrientation = .landscapeLeft
                self.bufferOrientation = .upMirrored
            case .landscapeRight:
                self.cameraController.previewLayer?.connection?.videoOrientation = .landscapeRight
                self.bufferOrientation = .downMirrored
            default:
                self.cameraController.previewLayer?.connection?.videoOrientation = .portrait
            }
        } else {
            self.cameraController.previewLayer?.connection?.videoOrientation = .portrait
        }
    }
    
    func startCamera() {
        previewView = UIView()
        previewView.contentMode = .scaleAspectFit
        previewView.translatesAutoresizingMaskIntoConstraints = false
                        
        if !view.subviews.contains(previewView) {
            view.addSubview(previewView)
            let constraints = [
                previewView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                previewView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                previewView.widthAnchor.constraint(equalTo: view.widthAnchor),
                previewView.heightAnchor.constraint(equalTo: view.heightAnchor),
                previewView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8),
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8)
            ]
            NSLayoutConstraint.activate(constraints)
        }
                
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if let captureSession = self.cameraController.captureSession, captureSession.canAddOutput(dataOutput) {
                self.cameraController.captureSession?.addOutput(dataOutput)
            }
            
            try? self.cameraController.displayPreview(on: self.previewView)
        }
    }
    
    func stopCamera() {
        cameraController.captureSession?.stopRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            let alert = UIAlertController(title: "Grant Access", message: "Enable AirChime to access your device's camera in the Settings app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        // Check that we have both points.
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else { return }
        let thumbPointConverted = self.cameraController.previewLayer!.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = self.cameraController.previewLayer!.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        
        // Process new points
        gestureProcessor?.processPointsPair(pointsPair: (thumbPointConverted, indexPointConverted))
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
            }
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest])
            // Continue only when a hand was detected in the frame.
            // Since we set the maximumHandCount property of the request to 1, there will be at most one observation.
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            // Get points for thumb and index finger.
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                return
            }
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return
            }
            // Convert points from Vision coordinates to AVFoundation coordinates.
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            cameraController.captureSession?.stopRunning()
            print("error occured")
        }

    }
}

struct CameraFeedView : UIViewControllerRepresentable {
    
    @Binding var cameraIsPlaying: Bool
    var gestureProcessor: HandGestureModel
    
    public typealias UIViewControllerType = CameraViewController
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
//        cameraVC.delegate = context.coordinator
        cameraVC.gestureProcessor = gestureProcessor
        return cameraVC
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if cameraIsPlaying {
            if let captureSession = uiViewController.cameraController.captureSession, !captureSession.isRunning {
                uiViewController.startCamera()
            }
        } else {
            uiViewController.stopCamera()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
//        let musicManager: MusicManager
        
//        init(musicManager: MusicManager) {
//            self.musicManager = musicManager
//        }
        
//        func didPrimaryHandClassificationOccur(_ viewController: CameraViewController, prediction: [(String, Double)]) {
//            let poseName = prediction.first?.0 ?? ""
//            let confidence = prediction.first?.1 ?? 0.0
//            if confidence >= highConfidenceThreshold {
//                if (poseName == lastIdentifiedPose && !lastPoseConfident) || (poseName != lastIdentifiedPose) {
//                    if consistencyCount < consistencyCountThreshold {
//                        consistencyCount += 1
//                        return
//                    }
//                    lastIdentifiedPose = poseName
//                    musicManager.updateCurrentNote(from: poseName)
//                    consistencyCount = 0
//                    lastPoseConfident = true
//                }
//
//            } else if confidence >= satisfactoryThreshold {
//                if (confidence - prediction[1].1) >= satisfactoryConfidenceDifference {
//                    if (poseName == lastIdentifiedPose && !lastPoseConfident) || (poseName != lastIdentifiedPose) {
//                        if consistencyCount < consistencyCountThreshold {
//                            consistencyCount += 1
//                            return
//                        }
//                        lastIdentifiedPose = poseName
//                        musicManager.updateCurrentNote(from: poseName)
//
//                        lastPoseConfident = true
//                    }
//                }
//            } else if confidence <= lowConfidenceThreshold {
//                lastPoseConfident = false
//                if consistencyCount > 0 { consistencyCount = 0 }
//            }
//        }
//
////        func didSecondaryHandClassificationOccur(_ viewController: CameraViewController, poseName: String, confidence: Double) {
////            if confidence >= highConfidenceThreshold {
////                musicManager.secondHandPoseDriver.userDidUpdatePose(Int(poseName) ?? -1)
////                secondHandPresent = true
////            }
////        }
////
////        func userDidRemoveSecondaryHand(_ viewController: CameraViewController) {
////            if secondHandPresent {
////                musicManager.secondHandPoseDriver.userDidRemoveSecondHand()
////                secondHandPresent = false
////            }
////        }
    }
}
