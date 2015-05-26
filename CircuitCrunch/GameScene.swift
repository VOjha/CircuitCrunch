//
//  GameScene.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/22/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var swipeHandler: ((Swap) -> ())?
    
    var level: Level!
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let circuitsLayer = SKNode()
    let tilesLayer = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        circuitsLayer.position = layerPosition
        gameLayer.addChild(circuitsLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
    }
    
    func addSpritesForCircuits(circuits: Set<Circuit>) {
        for circuit in circuits {
            let sprite = SKSpriteNode(imageNamed: circuit.circuitType.spriteName)
            sprite.position = pointForColumn(circuit.column, row: circuit.row)
            circuitsLayer.addChild(sprite)
            circuit.sprite = sprite
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * TileWidth + TileWidth/2,
            y: CGFloat(row) * TileHeight + TileHeight/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth && point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
            return (true, Int(point.x/TileWidth), Int(point.y/TileHeight))
        } else {
            return (false, 0, 0)
        }
        
    }
    
    func addTiles() {
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let tile = level.tileAtColumn(column, row: row) {
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(circuitsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            if let cookie = level.circuitAtColumn(column, row: row) {
                
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if swipeFromColumn == nil { return }
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(circuitsLayer)
        
        let (success, column, row) = convertPoint(location)
        
        if success {
            
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {
                horzDelta = -1
            } else if column > swipeFromColumn! {
                horzDelta = 1
            } else if row < swipeFromRow! {
                vertDelta = -1
            } else if row > swipeFromRow! {
                vertDelta = 1
            }
            
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                
                swipeFromColumn = nil
            }
            
        }
        
    }
    
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        if toColumn < 0 || toColumn >= NumColumns { return }
        if toRow < 0 || toRow >= NumRows { return }
        
        if let toCircuit = level.circuitAtColumn(toColumn, row: toRow) {
            if let fromCircuit = level.circuitAtColumn(swipeFromColumn!, row: swipeFromRow!) {
                if let handler = swipeHandler {
                    let swap = Swap(circuitA: fromCircuit, circuitB: toCircuit)
                    handler(swap)
                }
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    func animateSwap(swap: Swap, completion: ()->()) {
        let spriteA = swap.circuitA.sprite!
        let spriteB = swap.circuitB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
    }
    
}






























