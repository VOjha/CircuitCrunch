//
//  Extensions.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/26/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

import Foundation

extension Dictionary {
    
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var error: NSError?
            
            let data: NSData?
            do {
                data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())
            } catch var error1 as NSError {
                error = error1
                data = nil
            }
            
            if let data = data {
                let dictionary: AnyObject?
                do {
                    dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                } catch var error1 as NSError {
                    error = error1
                    dictionary = nil
                }
                
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    print("Level file '\(filename)' is not valid JSON: \(error!)")
                    return nil
                }
            } else {
                print("Could not load level file: \(filename), error: \(error!)")
                return nil
            }
            
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
        
    }
    
}
