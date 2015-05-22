//
//  Level.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/22/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {
    
    private var circuits = Array2D<Circuit>(columns: NumColumns, rows: NumRows)
    
    func circuitAtColumn(column: Int, row: Int) -> Circuit? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return circuits[column, row]
    }
    
    func shuffle() -> Set<Circuit> {
        return createInitialCircuits()
    }
    
    private func createInitialCircuits() -> Set<Circuit> {
        var set = Set<Circuit>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                var circuitType = CircuitType.random()
                
                let circuit = Circuit(column: column, row: row, circuitType: circuitType)
                circuits[column, row] = circuit
                
                set.insert(circuit)
            }
        }
        
        return set
    }
    
}
