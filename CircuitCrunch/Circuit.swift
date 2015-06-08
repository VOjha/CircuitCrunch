//
//  Circuit.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/22/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

import SpriteKit
    
enum CircuitType: Int, CustomStringConvertible {
    case Unknown = 0, Sensor, Threshold, Electronics, Circuit, Memory, Robot
    
    var spriteName: String {
        let spriteNames = [
        "Sensor",
        "Threshold",
        "Electronics",
        "Circuit",
        "Memory",
        "Robot"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    static func random() -> CircuitType {
        return CircuitType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}

class Circuit: CustomStringConvertible, Hashable {
    
    var column: Int
    var row: Int
    
    let circuitType: CircuitType
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, circuitType: CircuitType) {
        self.column = column
        self.row = row
        self.circuitType = circuitType
    }
    
    var description: String {
        return "type: \(circuitType) square: (\(column), \(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
    
}

func ==(lhs: Circuit, rhs: Circuit) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}









