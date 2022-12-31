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

            // あまりに長い住所はカタカナでぶった切る　たいていマンション名の前　ただノケは除く
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
        // あまりに長い住所はカタカナでぶった切る　たいていマンション名の前　ただノケは除く
        // ノは地名でも使われることがあるから... でもノではじまるマンションあったらいかんなあ

        let regex = try! NSRegularExpression(pattern: "[ア-グコ-ネハ-ン]")
        let range = regex.rangeOfFirstMatch(in:str, options:[], range:NSMakeRange(0, str.utf16.count))
        if range.location == NSNotFound || str.utf16.count<16 {
            return str+","
        }
        let start = str.index(str.startIndex, offsetBy: range.location)     // swift は文字列めんどくさすぎるんじゃあ
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

