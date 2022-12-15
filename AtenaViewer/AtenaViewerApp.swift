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
            CommandGroup(after: .newItem) {
                SaveAsNengaKazokuCSV()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            CommandGroup(after: .newItem) {
                SaveAsKitamuraCSV()
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
            Text("XMLを開く...")
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


struct SaveAsNengaKazokuCSV: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body : some View {
        Button (action: {
            let head = "\"お名前（姓）※必須\",\"お名前（名）※必須\",\"敬称※必須\",\"フリガナ（セイ）\",\"フリガナ（メイ）\",\"自宅郵便番号※必須\",\"自宅住所１※必須\",自宅住所２,自宅住所３,自宅住所４,様方,連名１（姓）,連名１（名）,連名１敬称,連名２（姓）,連名２（名）,連名２敬称,連名３（姓）,連名３（名）,連名３敬称,連名４（姓）,連名４（名）,連名４敬称,連名５（姓）,連名５（名）,連名５敬称,\"会社名１※法人の場合必須\",会社名２,部署名１,部署名２,役職１,役職２,\"会社郵便番号※法人の場合必須\",\"会社住所１※法人の場合必須\",会社住所２,会社住所３,会社住所４,会社連名１（姓）,会社連名１（名）,会社連名１敬称,会社連名１役職,会社連名１役職２行目,会社連名２（姓）,会社連名２（名）,会社連名２敬称,会社連名２役職１行目,会社連名２役職２行目"
            var alladdr: [Item] = []
            let fetchRequest = Item.fetchRequest()
            do
            {
                alladdr = try viewContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch \(error) \(error.userInfo)")
            }
            
            // 年賀家族形式：ヘッダ+CRLF＋(データ(SJIS)+CRLF)xn
            var str = head + "\r\n"
            for item in alladdr
            {   var str2 = (item.lastName ?? "") + "," + (item.firstName ?? "")
                str2 += "," + (item.suffix ?? "")
                str2 += "," + (item.furiLastName  ?? "")
                str2 += "," + (item.furiFirstName  ?? "")
                str2 += "," + (item.addressCode  ?? "")
                str2 += "," + insertCommaBeforeKatakana(str: (item.fullAddress  ?? ""))             // 余りに長い住所はカタカナでぶった切る　たいていマンション名の前
                str2 += ",,,"
                str2 += ",,,"  // Name of Family1
                str2 += ",,,"
                str2 += ",,,"
                str2 += ",,,"
                str2 += ",,,"
                str2 += ",,,,,,,"
                str2 += ",,,,,,,,"
                str2 += ",,,,,,"

                str += str2

                str += "\r\n"  // CRLF
            }

            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = "atena_nengaKazoku_SJIS.csv"
            savePanel.begin { (result) in
                if result == .OK {
                    guard let url = savePanel.url else { return }
                    //print(url.absoluteString)
                    do {
                        try str.write(to: url, atomically: true, encoding: String.Encoding.shiftJIS) // utf8
                    } catch {
                        // failed to write file (bad permissions, bad filename etc.)
                    }
                }
            }

        }, label: {
            Text("年賀家族CSVとして保存...")
        })
    }
}

struct SaveAsKitamuraCSV: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body : some View {
        Button (action: {
            let head = "姓1,名1,敬称1,姓2,名2,敬称2,姓3,名3,敬称3,姓4,名4,敬称4,姓5,名5,敬称5,姓6,名6,敬称6,〒番号,住所1,住所2,住所3,会社名,部署,役職,御中"
            var alladdr: [Item] = []
            let fetchRequest = Item.fetchRequest()
            do
            {
                alladdr = try viewContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch \(error) \(error.userInfo)")
            }
            
            // キタムラ形式：ヘッダ+CRLF＋(データ(SJIS)+CRLF)xn
            var str = head + "\r\n"
            for item in alladdr
            {   var str2 = (item.lastName ?? "") + "," + (item.firstName ?? "")
                str2 += "," + (item.suffix ?? "")
                str2 += ",,,"  // Name of Family1
                str2 += ",,,"
                str2 += ",,,"
                str2 += ",,,"
                str2 += ",,,"
                str2 += "," + (item.addressCode  ?? "")
                str2 += "," + insertCommaBeforeKatakana(str: (item.fullAddress  ?? ""))
                str2 += ",,,,,"

                str += str2

                str += "\r\n"  // CRLF
            }

            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = "atena_kitamura_SJIS.csv"
            savePanel.begin { (result) in
                if result == .OK {
                    guard let url = savePanel.url else { return }
                    //print(url.absoluteString)
                    do {
                        try str.write(to: url, atomically: true, encoding: String.Encoding.shiftJIS) // utf8
                    } catch {
                        // failed to write file (bad permissions, bad filename etc.)
                    }
                }
            }

        }, label: {
            Text("キタムラCSVとして保存...")
        })
    }
}

func insertCommaBeforeKatakana(str: String) -> String
{
    let regex = try! NSRegularExpression(pattern: "[ア-ネハ-ン]")  // ノは地名でも使われることがあるから... でもノではじまるマンションあったらいかんなあ
    let range = regex.rangeOfFirstMatch(in:str, options:[], range:NSMakeRange(0, str.utf16.count))
    if range.location == NSNotFound || str.utf16.count<16 {
        return str+","
    }
    let start = str.index(str.startIndex, offsetBy: range.location)     // swift は文字列めんどくさすぎるんじゃあ
    var str2 = str
    str2.insert(contentsOf: ",", at: start)
    return str2
}
