//
//  AtenaViewerApp.swift
//  AtenaViewer
//
//  Created by namikare gikoha on 2022/12/08.
//

import SwiftUI

@main
struct AtenaViewerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
