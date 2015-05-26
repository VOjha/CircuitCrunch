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
                
                if tiles[column, row] != nil {
                
                    var circuitType = CircuitType.random()
                
                    let circuit = Circuit(column: column, row: row, circuitType: circuitType)
                    circuits[column, row] = circuit
                
                    set.insert(circuit)
                }
            }
        }
        
        return set
    }
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    init(filename: String) {
        
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"] {
                for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {
                    let tileRow = NumRows - row - 1
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }
    
}
