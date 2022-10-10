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
                ZStack(alignment: .bottom) {
                    CameraFeedView(cameraIsPlaying: .constant(true), gestureProcessor: handGestureProcessor)
                        .onTapGesture {
                            handGestureProcessor.nextWord()
                        }
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
                    
                    translationPanel
                        .padding(.bottom, 24)
                }
            }
        }
    }
    
    var translationPanel: some View {
        VStack {
            morseCodeTranslationView
            
            Text(handGestureProcessor.morseTranslation.translatedText)
                .bold()
                .font(.system(.title, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(height: 100)
                        
            Text("Tap for next word.")
                .font(.subheadline)
        }
        .padding()
        .frame(minHeight: 150)
        .frame(maxWidth: 350)
        .background(.thinMaterial)
        .cornerRadius(8.0)
    }
    
    var morseCodeTranslationView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(handGestureProcessor.morseTranslation.morseCode) { code in
                    codeView(for: code.codeType)
                }
                .foregroundColor(.primary)
                
                if let tempPose = handGestureProcessor.tempPose {
                    codeView(for: tempPose)
                        .foregroundStyle(.thinMaterial)
                }
            }
        }
        .frame(height: 20)
        .animation(.easeInOut, value: handGestureProcessor.tempPose)
    }
    
    @ViewBuilder
    func codeView(for code: MorseCode.CodeType) -> some View {
        switch code {
        case .dot: Circle()
        case .dash: RoundedRectangle(cornerRadius: 8.0).frame(width: 50)
        case .charSpace:
            Rectangle()
                .fill(Color.red)
                .frame(width: 25)
        case .wordSpace:
            Rectangle()
                .fill(Color.blue)
                .frame(width: 25)
        }
    }
}

struct CameraModeView_Previews: PreviewProvider {
    static var previews: some View {
        CameraModeView()
    }
}
