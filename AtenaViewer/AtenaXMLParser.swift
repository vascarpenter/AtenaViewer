//
//  AtenaXMLParser.swift
//  AtenaViewer
//
//  Created by namikare gikoha on 2022/12/08.
//

import Foundation
import CoreData

class AtenaXMLParser: NSObject, XMLParserDelegate {
    
    var currentElementName: String!
    var pronun: String!
    var item: Item!
    var viewContext: NSManagedObjectContext!
    var cnt: Int32 = 0
    
    func loadData(url: URL, context: NSManagedObjectContext)
    {
        viewContext = context
        let data =  try! Data(contentsOf: url)
        let parser = XMLParser(data: data)
        cnt = 1
        parser.delegate = self
        parser.parse()
    }

    func parserDidStartDocument(_ parser: XMLParser)
    {
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        currentElementName = elementName
        if(elementName == "ContactXMLItem")
        {
            // new person
            item = Item(context: viewContext)
        }

        if(elementName == "FirstName" || elementName == "LastName")
        {
            if let pro = attributeDict["pronunciation"]
            {
                pronun = pro
            }
        }
        if(elementName == "ExtensionItem")
        {
            if let extType = attributeDict["name"]
            {
                currentElementName = extType
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        switch currentElementName {
        case "FirstName":
            item.firstName = string
            item.furiFirstName = pronun ?? ""
        case "LastName":
            item.lastName = string
            item.furiLastName = pronun ?? ""
        case "AddressCode":
            item.addressCode = string
        case "FullAddress":
            item.fullAddress = string
        case "X-NYCardHistory":
            item.nyCardHistory = string
        case "Suffix":
            item.suffix = string
        case "NamesOfFamily":
            // 複数回出現
            if (item.nameOfFamily1==nil)
            {
                item.nameOfFamily1 = string
            }
            else if (item.nameOfFamily2==nil)
            {
                item.nameOfFamily2 = string
            }
            else if (item.nameOfFamily3==nil)
            {
                item.nameOfFamily3 = string
            }
        case "X-Suffix1":
            item.suffix1 = string
        case "X-Suffix2":
            item.suffix2 = string
        case "X-Suffix3":
            item.suffix3 = string
        case "atxBaseYear":
            item.atxBaseYear = Int32(string) ?? 0
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if item != nil && elementName == "ContactXMLItem"
        {
            item.id = cnt
            cnt = cnt+1
        }
        currentElementName = nil
    }
    
    func parserDidEndDocument(_ parser: XMLParser)
    {
        try! viewContext.save()
    }
}
