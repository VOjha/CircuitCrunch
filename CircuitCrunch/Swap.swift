//
//  Swap.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/26/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

struct Swap: Printable, Hashable {
    
    let circuitA: Circuit
    let circuitB: Circuit
    
    init(circuitA: Circuit, circuitB: Circuit) {
        self.circuitA = circuitA
        self.circuitB = circuitB
    }
    
    var description: String {
        return "swap \(circuitA) with \(circuitB)"
    }
    
    var hashValue: Int {
        return circuitA.hashValue ^ circuitB.hashValue
    }
    
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.circuitA == rhs.circuitA && lhs.circuitB == rhs.circuitB) ||
           (lhs.circuitB == rhs.circuitA && lhs.circuitA == rhs.circuitB)
}
