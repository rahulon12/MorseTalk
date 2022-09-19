//
//  ButtonModeDriver.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/18/22.
//

import SwiftUI

class ButtonModeDriver: ObservableObject {
    
    private var isPressed = false
    private var timer: Timer?
    @Published var counter: Int = 0 {
        didSet { print(counter) }
    }
    
    // MARK: - User Intents
    func didPressButtonDown() {
        if !isPressed {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                self.counter += 1
            })
            isPressed = true
        }
    }
    
    func didReleaseButton() {
        timer?.invalidate()
        counter = 0
        isPressed = false
    }
    
    
    
}
