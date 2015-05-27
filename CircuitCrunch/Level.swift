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
    
    var targetScore = 0
    var maximumMoves = 0
    
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
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
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
    
    private func detectHorizontalMatches() -> Set<Chain> {
        
        var set = Set<Chain>()
        
        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2; {
                
                if let circuit = circuits[column, row] {
                    let matchType = circuit.circuitType
                    
                    if circuits[column+1, row]?.circuitType == matchType && circuits[column+2, row]?.circuitType == matchType {
                        let chain = Chain(chainType: .Horizontal)
                        do {
                        chain.addCircuit(circuits[column, row]!)
                        ++column
                        }
                        while column < NumColumns && circuits[column, row]?.circuitType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                    
                }
                ++column
            }
        }
        return set
    }
    
    private func detectVerticalMatches() -> Set<Chain> {
        
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                
                if let circuit = circuits[column, row] {
                    let matchType = circuit.circuitType
                    
                    if circuits[column, row+1]?.circuitType == matchType && circuits[column, row+2]?.circuitType == matchType {
                        let chain = Chain(chainType: .Vertical)
                        do {
                        chain.addCircuit(circuits[column, row]!)
                        ++row
                        }
                        while row < NumRows && circuits[column, row]?.circuitType == matchType
                        
                        set.insert(chain)
                        continue
                    }
                    
                }
                ++row
            }
        }
        return set
    }
    
    func removeMatches() -> Set<Chain> {
        
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removeCircuits(horizontalChains)
        removeCircuits(verticalChains)
        
        return horizontalChains.union(verticalChains)
        
    }
    
    private func removeCircuits(chains: Set<Chain>) {
        
        for chain in chains {
            for circuit in chain.circuits {
                circuits[circuit.column, circuit.row] = nil
            }
        }
        
    }
    
    func fillHoles() -> [[Circuit]] {
        
        var columns = [[Circuit]]()
        
        for column in 0..<NumColumns {
            var array = [Circuit]()
            for row in 0..<NumRows {
                if tiles[column, row] != nil && circuits[column, row] == nil {
                    for lookup in (row+1)..<NumRows {
                        if let circuit = circuits[column, lookup] {
                            circuits[column, lookup] = nil
                            circuits[column, row] = circuit
                            circuit.row = row
                            
                            array.append(circuit)
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpCircuits() -> [[Circuit]] {
        var columns = [[Circuit]]()
        var circuitType: CircuitType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Circuit]()
            
            for var row = NumRows - 1; row >= 0 && circuits[column, row] == nil; --row {
                
                if tiles[column, row] != nil {
                    
                    var newCircuitType: CircuitType
                    do {
                        newCircuitType = CircuitType.random()
                    } while newCircuitType == circuitType
                    circuitType = newCircuitType
                    
                    let circuit = Circuit(column: column, row: row, circuitType: circuitType)
                    circuits[column, row] = circuit
                    array.append(circuit)
                }
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
}

























