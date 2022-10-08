//
//  CameraModeView.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/10/22.
//

import SwiftUI

struct CameraModeView: View {
    @Environment(\.dismiss) var dismiss
    let morseCodeTranslation = MorseCodeTranslation()
    @ObservedObject private var handGestureProcessor = HandGestureModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("\(handGestureProcessor.currentState.rawValue)")
                Text("pinching for \(handGestureProcessor.timePinchedCount)")
                ZStack {
                    CameraFeedView(cameraIsPlaying: .constant(true), gestureProcessor: handGestureProcessor)
                        .background(Color.gray)
                        .cornerRadius(AppConstants.defaultCornerRadius)
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button { dismiss() } label: {
                                    Label("Dismiss", systemImage: "xmark.circle.fill")
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { dismiss() }
                            }
                        }
                }
            }
        }
    }
}

struct CameraModeView_Previews: PreviewProvider {
    static var previews: some View {
        CameraModeView()
    }
}
