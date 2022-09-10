//
//  MorseTalkApp.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/10/22.
//

import SwiftUI

@main
struct MorseTalkApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
