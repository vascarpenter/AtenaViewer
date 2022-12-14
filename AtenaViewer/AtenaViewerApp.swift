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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init()
    {
        cleanUp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                // remove New Window
            }
            CommandGroup(after: .newItem) {
                OpenFileItem()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            CommandGroup(replacing: .help) {
                ShowHelpItem()
            }
        }
    }

    func cleanUp() {
        let viewContext = persistenceController.container.viewContext
        for entity in persistenceController.container.managedObjectModel.entities {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity.name!)
            let results = try! viewContext.fetch(fetchRequest)
            for result in results {
                viewContext.delete(result)
            }
        }

        if viewContext.hasChanges {
            try! viewContext.save()
        }
    }

}


struct OpenFileItem: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body : some View {
        Button (action: {
            let openPanel = NSOpenPanel()
            openPanel.allowsMultipleSelection = false
            openPanel.canChooseDirectories = false
            openPanel.canCreateDirectories = false
            openPanel.canChooseFiles = true
            openPanel.begin { (result) -> Void in
                if result == .OK {
                    guard let url = openPanel.url else { return }
                    let parser = AtenaXMLParser()
                    parser.loadData(url: url, context: viewContext)
                }
            }
        }, label: {
            Text("Open XML...")
        })
        .keyboardShortcut("O", modifiers:  [.command])
    }
}

struct ShowHelpItem: View {
    var body : some View {
        Button (action: {
            NSWorkspace.shared.open(URL(string: "https://github.com/vascarpenter/")!)
        }, label: {
            Text("show website")
        })
    }
}

class AppDelegate: NSObject, NSApplicationDelegate/*, NSWindowDelegate*/ {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        /*
         let rmMenuTitles = Set(["File"])
         
         if let mainMenu = NSApp.mainMenu {
         let menus = mainMenu.items.filter { item in
         return rmMenuTitles.contains(item.title)
         }
         for i in menus {
         mainMenu.removeItem(i)
         }
         }
         */
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // close app after last window closed
        return true
    }
    
}

