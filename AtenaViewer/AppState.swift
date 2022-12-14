//
//  AppState.swift
//  AtenaViewer
//
//  Created by Namikare Gikoha on 2022/12/19.
//

import SwiftUI

class AppState: ObservableObject {

    func OpenFileItem()
    {
        
        let viewContext = PersistenceController.shared.container.viewContext

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.begin { (result) -> Void in
            if result == .OK {
                // remove all core data object
                self.cleanCoreDataObject()

                guard let url = openPanel.url else { return }
                let parser = AtenaXMLParser()
                parser.loadData(url: url, context: viewContext)
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }

            }
        }
    }
    
    func SaveAsXML()
    {
        let viewContext = PersistenceController.shared.container.viewContext

        var alladdr: [Item] = []
        let fetchRequest = Item.fetchRequest()

        do
        {
            alladdr = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error) \(error.userInfo)")
        }

        var str = """
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE ContactXML SYSTEM "ContactXML_01_01_20020615.dtd">
<ContactXML xmlns="http://www.xmlns.org/2002/ContactXML" creator="http://www.agenda.co.jp/atena-shokunin/mac/2.0" version="1.1">\n
"""
        for item in alladdr
        {
            str += """
<ContactXMLItem><PersonName><PersonNameItem xml:lang="ja-JP">\n
"""
            str += String(format: "<FullName pronunciation=\"%@ %@\">%@ %@</FullName>\n", item.furiLastName ?? "", item.furiFirstName ?? "",
                           item.lastName ?? "", item.firstName ?? "")
            str += String(format: "<FirstName pronunciation=\"%@\">%@</FirstName>\n",  item.furiFirstName ?? "", item.firstName ?? "")
            str += String(format: "<LastName pronunciation=\"%@\">%@</LastName>\n",  item.furiLastName ?? "", item.lastName ?? "")
            str += """
</PersonNameItem>
</PersonName>
<Address>
<AddressItem locationType="Home" preference="True" xml:lang="ja-JP">
<AddressCode codeDomain="ZIP7">
"""
            str += String(format: "%@</AddressCode>\n<FullAddress>%@</FullAddress>",  item.addressCode ?? "", item.fullAddress ?? "")
            str += """
</AddressItem>
<AddressItem locationType="Office" xml:lang="ja-JP">
<AddressCode codeDomain="ZIP7"></AddressCode>
<FullAddress></FullAddress>
</AddressItem>
<AddressItem locationType="Others" xml:lang="ja-JP">
<AddressCode codeDomain="ZIP7"></AddressCode>
<FullAddress></FullAddress>
</AddressItem>
</Address>
<Phone></Phone>
<Extension>
<ExtensionItem extensionType="Common" name="Suffix" xml:lang="ja-JP">
"""
            str += String(format: "%@</ExtensionItem>\n",  item.suffix ?? "")
            if let nameoffam = item.nameOfFamily1 {
                str += String(format: "<ExtensionItem extensionType=\"Common\" name=\"NamesOfFamily\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              nameoffam)
                str += String(format: "<ExtensionItem extensionType=\"Extended\" name=\"X-Suffix1\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              item.suffix1 ?? "")
            }
            if let nameoffam2 = item.nameOfFamily2 {
                str += String(format: "<ExtensionItem extensionType=\"Common\" name=\"NamesOfFamily\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              nameoffam2)
                str += String(format: "<ExtensionItem extensionType=\"Extended\" name=\"X-Suffix2\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              item.suffix2 ?? "")
            }
            if let nameoffam3 = item.nameOfFamily3 {
                str += String(format: "<ExtensionItem extensionType=\"Common\" name=\"NamesOfFamily\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              nameoffam3)
                str += String(format: "<ExtensionItem extensionType=\"Extended\" name=\"X-Suffix3\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              item.suffix3 ?? "")
            }
            if let nycard = item.nyCardHistory {
                str += String(format: "<ExtensionItem extensionType=\"Extended\" name=\"X-NYCardHistory\" xml:lang=\"ja-JP\">%@</ExtensionItem>\n",
                              nycard)
            }
            if item.atxBaseYear != 0 {
                str += String(format: "<ExtensionItem extensionType=\"Extended\" name=\"atxBaseYear\" xml:lang=\"ja-JP\">%d</ExtensionItem>\n",
                              item.atxBaseYear)
            }

            str += "</Extension>\n</ContactXMLItem>\n"
        }
        str += "</ContactXML>\n"

        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "atenaviewer.xml"
        savePanel.begin { (result) in
            if result == .OK {
                guard let url = savePanel.url else { return }
                //print(url.absoluteString)
                do {
                    try str.write(to: url, atomically: true, encoding: String.Encoding.utf8) // utf8
                } catch {
                    // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }

    }
    
    func SaveAsNengaKazokuCSV()
    {
        let viewContext = PersistenceController.shared.container.viewContext
        
        let head = "\"???????????????????????????\",\"???????????????????????????\",\"???????????????\",\"????????????????????????\",\"????????????????????????\",\"???????????????????????????\",\"????????????????????????\",???????????????,???????????????,???????????????,??????,??????????????????,??????????????????,???????????????,??????????????????,??????????????????,???????????????,??????????????????,??????????????????,???????????????,??????????????????,??????????????????,???????????????,??????????????????,??????????????????,???????????????,\"????????????????????????????????????\",????????????,????????????,????????????,?????????,?????????,\"??????????????????????????????????????????\",\"???????????????????????????????????????\",???????????????,???????????????,???????????????,????????????????????????,????????????????????????,?????????????????????,?????????????????????,??????????????????????????????,????????????????????????,????????????????????????,?????????????????????,??????????????????????????????,??????????????????????????????"
        var alladdr: [Item] = []
        let fetchRequest = Item.fetchRequest()

        do
        {
            alladdr = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error) \(error.userInfo)")
        }
        
        // ??????????????????????????????+CRLF???(?????????(SJIS)+CRLF)xn
        var str = head + "\r\n"
        for item in alladdr
        {   var str2 = (item.lastName ?? "") + "," + (item.firstName ?? "")
            str2 += "," + (item.suffix ?? "")
            str2 += "," + (item.furiLastName  ?? "")
            str2 += "," + (item.furiFirstName  ?? "")
            str2 += "," + (item.addressCode  ?? "")

            // ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
            str2 += "," + insertCommaBeforeKatakana(str: (item.fullAddress  ?? ""))
            str2 += ",,,"
            str2 += ",," + (item.nameOfFamily1  ?? "")  + "," + (item.suffix1  ?? "")  // Name of Family1
            str2 += ",," + (item.nameOfFamily2  ?? "")  + "," + (item.suffix2  ?? "")  // Name of Family2
            str2 += ",," + (item.nameOfFamily3  ?? "")  + "," + (item.suffix3  ?? "")  // Name of Family3
            str2 += ",,,"
            str2 += ",,,,,,,"
            str2 += ",,,,,,,,"
            str2 += ",,,,,,,,,"

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

    }
    
    func SaveAsKitamuraCSV()
    {
        let viewContext = PersistenceController.shared.container.viewContext
        let head = "???1,???1,??????1,???2,???2,??????2,???3,???3,??????3,???4,???4,??????4,???5,???5,??????5,???6,???6,??????6,?????????,??????1,??????2,??????3,?????????,??????,??????,??????"
        var alladdr: [Item] = []
        let fetchRequest = Item.fetchRequest()
        do
        {
            alladdr = try viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error) \(error.userInfo)")
        }
        
        // ??????????????????????????????+CRLF???(?????????(SJIS)+CRLF)xn
        var str = head + "\r\n"
        for item in alladdr
        {   var str2 = (item.lastName ?? "") + "," + (item.firstName ?? "")
            str2 += "," + (item.suffix ?? "")
            str2 += ",," + (item.nameOfFamily1  ?? "")  + "," + (item.suffix1  ?? "")  // Name of Family1
            str2 += ",," + (item.nameOfFamily2  ?? "")  + "," + (item.suffix2  ?? "")  // Name of Family2
            str2 += ",," + (item.nameOfFamily3  ?? "")  + "," + (item.suffix3  ?? "")  // Name of Family3
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

    }
    
    func insertCommaBeforeKatakana(str: String) -> String
    {
        // ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
        // ???????????????????????????????????????????????????... ??????????????????????????????????????????????????????????????????

        let regex = try! NSRegularExpression(pattern: "[???-??????-??????-???]")
        let range = regex.rangeOfFirstMatch(in:str, options:[], range:NSMakeRange(0, str.utf16.count))
        if range.location == NSNotFound || str.utf16.count<16 {
            return str+","
        }
        let start = str.index(str.startIndex, offsetBy: range.location)     // swift ????????????????????????????????????????????????
        var str2 = str
        str2.insert(contentsOf: ",", at: start)
        return str2
    }

    func cleanCoreDataObject()
    {
        // remove all CoreData Object
        let viewContext = PersistenceController.shared.container.viewContext
        for entity in PersistenceController.shared.container.managedObjectModel.entities {
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

