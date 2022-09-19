//
//  CameraModeView.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/10/22.
//

import SwiftUI

struct CameraModeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                CameraFeedView(cameraIsPlaying: .constant(true))
//                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(AppConstants.defaultCornerRadius)
                    .frame(height: 250)
                    
                RoundedRectangle(cornerRadius: AppConstants.defaultCornerRadius)
                    .fill(.quaternary)
                    .overlay(Text("Morse"))
                    .frame(height: 100)
                Spacer()
                Text("Hello iOS Club! This is a translated sentence.")
                    .font(.largeTitle.bold())
                Spacer()
                Text("Hold button for each word.")
                    .font(.title3.bold())
                Button("Press") { }
                    .buttonStyle(.borderedProminent)
                    .font(.title.bold())
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

struct CameraModeView_Previews: PreviewProvider {
    static var previews: some View {
        CameraModeView()
    }
}
