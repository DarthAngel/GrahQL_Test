//  Transformers.swift
//  GrahQL_Test
//
//  Created by Angel Docampo on 31/8/25.
//

import Foundation

@objc(StringArrayTransformer)
final class StringArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    
    static let name = NSValueTransformerName("StringArrayTransformer")
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSString.self]
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        // Handle both [String] and NSArray input
        let array: [String]?
        if let stringArray = value as? [String] {
            array = stringArray
        } else if let nsArray = value as? NSArray {
            array = nsArray.compactMap { $0 as? String }
        } else {
            return nil
        }
        
        guard let array = array, !array.isEmpty else { return nil }
        
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
        } catch {
            print("Failed to transform array: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return NSArray() }
        
        do {
            let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)
            return unarchived ?? NSArray()
        } catch {
            print("Failed to reverse transform data: \(error)")
            return NSArray()
        }
    }
    
    @objc
    static func register() {
        let transformer = StringArrayTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
        print("StringArrayTransformer registered")
    }
}
