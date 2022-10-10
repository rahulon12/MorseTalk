import Foundation
import CoreGraphics

class HandGestureModel: ObservableObject {
    // Distance
    // The current state of the hand
    // The time of contact
    typealias PointsPair = (thumbTip: CGPoint, indexTip: CGPoint)
    let pinchThreshold: CGFloat
    let countThreshold = 3
    var tempPose: MorseCode.CodeType?
    
    enum HandState: String, CaseIterable {
        case pinched, apart, inProgress, unknown
    }
    
    @Published var timePinchedCount = 0.0 {
        didSet {
            if timePinchedCount > 3 {
                tempPose = .dash
            } else if timePinchedCount >= 1 {
                tempPose = .dot
            }
        }
    }
    var timePinchedTimer: Timer?
    var isPinchedCount = 0
    var isApartCount = 0
    @Published var morseTranslation: MorseCodeTranslation = MorseCodeTranslation()
    
    @Published var currentState: HandState = .unknown {
        willSet {
            if (currentState != .pinched && newValue == .pinched) {
                timePinchedTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.timePinchedCount += 1
                }
            }
        }
    }
    
    init(pinchThreshold: CGFloat = 40) {
        self.pinchThreshold = pinchThreshold
    }
    
    func processPointsPair(pointsPair: PointsPair) {
        let distance = pointsPair.indexTip.distance(from: pointsPair.thumbTip)
        if distance < pinchThreshold {
            isPinchedCount += 1
            isApartCount = 0
            currentState = (isPinchedCount > countThreshold) ? .pinched : .inProgress
        } else {
            isApartCount += 1
            isPinchedCount = 0
            // timePinchedTimer = 0
            currentState = (isApartCount > countThreshold) ? .apart : .inProgress
            timePinchedTimer?.invalidate()
            if let tempPose = tempPose {
                morseTranslation.morseCode.append(MorseCode(tempPose))
            }
            timePinchedCount = 0
            tempPose = nil
        }
    }
    
    func reset() {
        tempPose = nil
        timePinchedCount = 0
        timePinchedTimer?.invalidate()
        isApartCount = 0
        isPinchedCount = 0
        currentState = .unknown
    }
    
    func nextWord() {
        if morseTranslation.morseCode.last?.codeType != .wordSpace {
            morseTranslation.morseCode.append(MorseCode(.wordSpace))
        }
    }
}

extension CGPoint {
    func distance(from otherPoint: CGPoint) -> CGFloat {
        return hypot(self.x - otherPoint.x, self.y - otherPoint.y)
    }
    
}
