//
//  HomeView.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/10/22.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showButtonModeView = false
    @State private var showCameraModeView = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(1...10, id: \.self) { i in
                        Text("\(i)")
                    }
                } header: {
                    Text("History")
                }
            }
            .navigationTitle("MorseTalk")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            
                        } label: {
                            Label("Instructions", systemImage: "questionmark.circle")
                        }
                        Button {
                            
                        } label: {
                            Label("Practice", systemImage: "hand.wave")
                        }
                    } label: {
                        Label("More Options", systemImage: "ellipsis.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // TODO: Change names.
                        Button {
                            showButtonModeView = true
                        } label: {
                            Label("Button Mode", systemImage: "button.programmable")
                        }
                        Button {
                            showCameraModeView = true
                        } label: {
                            Label("Camera Mode", systemImage: "camera")
                        }
                    } label: {
                        Label("New", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showButtonModeView) {
            ButtonModeView()
        }
        .fullScreenCover(isPresented: $showCameraModeView) {
            CameraModeView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
