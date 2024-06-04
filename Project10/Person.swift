//
//  Person.swift
//  Project10
//
//  Created by Olha Pylypiv on 12.03.2024.
//

import UIKit

class Person: NSObject, NSCoding, NSSecureCoding {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        name = coder.decodeObject(forKey: "name") as? String ?? ""
        image = coder.decodeObject(forKey: "image") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(image, forKey: "image")
    }
    
    //static var secureCoding = true
    static var supportsSecureCoding: Bool { return true }
    //override public class var supportsSecureCoding: Bool { return secureCoding}
}
