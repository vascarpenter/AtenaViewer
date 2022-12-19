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
    @StateObject var appState = AppState()

    init()
    {
        cleanUp()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                // remove New Window
            }
            CommandGroup(after: .newItem) {
                Button (action: {
                    appState.OpenFileItem()
                }, label: {
                    Text("XMLを開く...")
                })
                .keyboardShortcut("O", modifiers:  [.command])
            }
            CommandGroup(after: .newItem) {
                Button (action: {
                    appState.SaveAsNengaKazokuCSV()
                }, label: {
                    Text("年賀家族CSVとして保存...")
                })
            }
            CommandGroup(after: .newItem) {
                Button (action: {
                    appState.SaveAsKitamuraCSV()
                }, label: {
                    Text("キタムラCSVとして保存...")
                })
            }
            CommandGroup(replacing: .help) {
                Button (action: {
                    NSWorkspace.shared.open(URL(string: "https://github.com/vascarpenter/AtenaViewer")!)
                }, label: {
                    Text("AtenaViwer ウェブサイトを表示")
                })
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
