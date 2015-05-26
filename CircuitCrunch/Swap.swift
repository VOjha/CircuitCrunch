//
//  Swap.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/26/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

struct Swap: Printable {
    
    let circuitA: Circuit
    let circuitB: Circuit
    
    init(circuitA: Circuit, circuitB: Circuit) {
        self.circuitA = circuitA
        self.circuitB = circuitB
    }
    
    var description: String {
        return "swap \(circuitA) with \(circuitB)"
    }
    
}
