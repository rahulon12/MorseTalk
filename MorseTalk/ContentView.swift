//
//  ContentView.swift
//  MorseTalk
//
//  Created by Rahul Narayanan on 9/10/22.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        HomeView()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
