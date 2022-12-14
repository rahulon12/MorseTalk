//
//  ButtonModeView.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/10/22.
//

import SwiftUI

struct ButtonModeView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var buttonModeDriver = ButtonModeDriver()
    
    var body: some View {
        NavigationView {
            VStack {
                RoundedRectangle(cornerRadius: AppConstants.defaultCornerRadius)
                    .fill(.quaternary)
                    .overlay(Text("Morse"))
                    .frame(height: 200)
                Spacer()
                Text("Hello World! This is a translated sentence.")
                    .font(.largeTitle.bold())
                Spacer()
                Text("Hold button for each word.")
                    .font(.title3.bold())
                Text("Press")
                    //.buttonStyle(.borderedProminent)
                    .font(.title.bold())
                    .gesture(DragGesture()
                        .onChanged({ _ in
                            buttonModeDriver.didPressButtonDown()
                        })
                            .onEnded({ _ in
                                buttonModeDriver.didReleaseButton()
                            }))
            }
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

struct ButtonModeView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonModeView()
    }
}
