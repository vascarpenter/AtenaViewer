//
//  ContentView.swift
//  AtenaViewer
//
//  Created by namikare gikoha on 2022/12/08.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var appState : AppState

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.furiLastName, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var showingAddSheet = false
    @State var selection: Item? = nil
    
    var body: some View {
        NavigationSplitView {
            List(items, id: \.self, selection: $selection) { item in
                let lastName = item.lastName ?? ""
                let firstName = item.firstName ?? ""
                
                Text("\(lastName) \(firstName) ")
                .contextMenu(ContextMenu(menuItems: {
                    Button(action: {
                        withAnimation {
                            viewContext.delete(item)
                            
                            do {
                                try viewContext.save()
                            } catch {
                                // Replace this implementation with code to handle the error appropriately.
                                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                        selection = nil
                    }, label: {
                        Label("削除", systemImage: "trash")
                            .foregroundColor(.red)
                    })
                    .keyboardShortcut(.delete, modifiers: [])
                }))
            }
        } detail: {
            if let sel = selection
            {
                VStack {
                    let lastName = sel.lastName ?? ""
                    let firstName = sel.firstName ?? ""
                    let addr = sel.addressCode ?? ""
                    let fullAddress = sel.fullAddress ?? ""
                    Text("\(lastName) \(firstName)")
                    Text("〒\(addr) \(fullAddress)")
                }
            }
            else
            {
                Text("Select")
            }
        }
        .toolbar {
            
            ToolbarItem {
                Button(action: {
                    self.showingAddSheet.toggle()
                }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .environmentObject(appState)
        .sheet(isPresented: $showingAddSheet) {
            AddSheet(viewContext: viewContext)
        }
    }

    private func deleteItem()
    {
        if
            let sel = self.selection,
            let idx = self.items.firstIndex(of: sel)
        {
            print("delete item: \(idx) \(sel)")
        }

    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var furiFname = ""
    @State private var furiLname = ""
    @State private var fname = ""
    @State private var lname = ""
    @State private var addrcode = ""
    @State private var addr = ""

    let viewContext : NSManagedObjectContext
    
    var body: some View {
        VStack {
            HStack {
                TextField("せい", text: $furiLname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("めい", text: $furiFname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                TextField("姓", text: $lname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("名", text: $fname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("〒")
                TextField("〒", text: $addrcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("住所")
                TextField("", text: $addr)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Button("追加") {
                    let calendar = Calendar(identifier: .gregorian)
                    let newItem = Item(context: viewContext)
                    
                    newItem.firstName = fname
                    newItem.lastName = lname
                    newItem.furiFirstName = furiFname
                    newItem.furiLastName = furiLname
                    newItem.addressCode = addrcode
                    newItem.fullAddress = addr
                    newItem.atxBaseYear = Int32(calendar.component(.year, from: Date()))
                    newItem.nyCardHistory = "00000000000000002007"
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }

                    dismiss()
                }
                Button("キャンセル") {
                    dismiss()
                }

            }
        }
        .padding(16.0)
        .frame(width: 400, height: 300)

    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

