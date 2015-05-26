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
    
    private var possibleSwaps = Set<Swap>()
    
    func circuitAtColumn(column: Int, row: Int) -> Circuit? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return circuits[column, row]
    }
    
    func shuffle() -> Set<Circuit> {
        var set: Set<Circuit>
        
        do {
            set = createInitialCircuits()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        }
        while possibleSwaps.count == 0
        
        return set
    }
    
    private func createInitialCircuits() -> Set<Circuit> {
        var set = Set<Circuit>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if tiles[column, row] != nil {
                
                    var circuitType: CircuitType
                    do {
                        circuitType = CircuitType.random()
                    }
                        while (column >= 2 &&
                            circuits[column - 1, row]?.circuitType == circuitType &&
                            circuits[column - 2, row]?.circuitType == circuitType)
                            || (row >= 2 &&
                                circuits[column, row - 1]?.circuitType == circuitType &&
                                circuits[column, row - 2]?.circuitType == circuitType)
                
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
    
    func performSwap(swap: Swap) {
        
        let columnA = swap.circuitA.column
        let rowA = swap.circuitA.row
        
        let columnB = swap.circuitB.column
        let rowB = swap.circuitB.row
        
        circuits[columnA, rowA] = swap.circuitB
        swap.circuitB.column = columnA
        swap.circuitB.row = rowA
        
        circuits[columnB, rowB] = swap.circuitA
        swap.circuitA.column = columnB
        swap.circuitA.row = rowB
        
    }
    
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        
        let circuitType = circuits[column, row]!.circuitType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && circuits[i, row]?.circuitType == circuitType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && circuits[i, row]?.circuitType == circuitType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && circuits[column, i]?.circuitType == circuitType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && circuits[column, i]?.circuitType == circuitType;
            ++i, ++vertLength { }
        return vertLength >= 3
        
    }
    
    func detectPossibleSwaps() {
        
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let circuit = circuits[column, row] {
                    
                    // Attempt swap on the right
                    if column < NumColumns - 1 {
                        if let other = circuits[column+1, row] {
                            circuits[column, row] = other
                            circuits[column+1, row] = circuit
                            
                            // Chain formed?
                            if hasChainAtColumn(column+1, row: row) || hasChainAtColumn(column, row: row) {
                                set.insert( Swap(circuitA: circuit, circuitB: other) )
                            }
                            
                            circuits[column, row] = circuit
                            circuits[column+1, row] = other
                        }
                    }
                    
                    // Attempt swap above
                    if row < NumRows - 1 {
                        if let other = circuits[column, row+1] {
                            circuits[column, row] = other
                            circuits[column, row+1] = circuit
                            
                            // Chain formed?
                            if hasChainAtColumn(column, row: row+1) || hasChainAtColumn(column, row: row+1) {
                                set.insert( Swap(circuitA: circuit, circuitB: other) )
                            }
                            
                            circuits[column, row] = circuit
                            circuits[column, row+1] = other
                            
                        }
                    }
                    
                }
            }
        }
        possibleSwaps = set
    }
    
    func isPossible(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
    
}

























