//
//  Chain.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/26/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

class Chain: Hashable, Printable {
    
    var circuits = [Circuit]()
    
    enum ChainType: Printable {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addCircuit(circuit: Circuit) {
        circuits.append(circuit)
    }
    
    func firstCircuit() -> Circuit {
        return circuits[0]
    }
    
    func lastCircuit() -> Circuit {
        return circuits[circuits.count - 1]
    }
    
    var length: Int {
        return circuits.count
    }
    
    var descrption: String {
        return "type: \(chainType) circuits: \(circuits)"
    }
    
    var hashValue: Int {
        return reduce(circuits, 0) { $0.hashValue ^ $1.hashValue }
    }
    
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.circuits == rhs.circuits
}
