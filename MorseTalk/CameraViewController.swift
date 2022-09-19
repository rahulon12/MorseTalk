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
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        let model: AirNotesPosesNew = try! AirNotesPosesNew(configuration: MLModelConfiguration.init())
//
//        let handler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: self.bufferOrientation, options: [:])
//
//        frameCounter += 1
//        if frameCounter != 4 {
//            return
//        }
//        frameCounter = 0
//
//        do {
//            try handler.perform([handPoseRequest])
//
//            guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
//                self.delegate?.didPrimaryHandClassificationOccur(self, prediction: [("", 0.0)])
////                self.delegate?.userDidRemoveSecondaryHand(self)
//                return
//            }
//            let handObservation = handPoses.first
//
//            guard let keypointsMultiArray = try? handObservation?.keypointsMultiArray()
//            else { fatalError() }
//
//            let handPosePrediction = try model.prediction(poses: keypointsMultiArray)
//            // let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label]!
//
//            let topPredictions = handPosePrediction.labelProbabilities.sorted(by: { $0.value > $1.value }).prefix(2)
////            for (_, v) in dict.enumerated() {
////                print(String(format: "\(v.key) %.2f", v.value))
////            }
////            print("\n\n")
//
//            self.delegate?.didPrimaryHandClassificationOccur(self, prediction: Array(topPredictions))
//
////            if handPoses.count > 1 {
////                let secondaryHandObservation = handPoses[1]
////
////                guard let keypointsMultiArray = try? secondaryHandObservation.keypointsMultiArray()
////                else { fatalError() }
////
////                let handPosePrediction = try model.prediction(poses: keypointsMultiArray)
////                let confidence = handPosePrediction.labelProbabilities[handPosePrediction.label]!
////
////                self.delegate?.didSecondaryHandClassificationOccur(self, poseName: handPosePrediction.label, confidence: confidence)
////            } else {
////                self.delegate?.userDidRemoveSecondaryHand(self)
////            }
//
//        } catch {
//            assertionFailure("Human Pose Request failed: \(error)")
//        }
        
    }
    
    
}

struct CameraFeedView : UIViewControllerRepresentable {
    
    @Binding var cameraIsPlaying: Bool
    
    public typealias UIViewControllerType = CameraViewController
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
//        cameraVC.delegate = context.coordinator
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
