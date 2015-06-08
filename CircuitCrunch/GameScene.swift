//
//  GameScene.swift
//  CircuitCrunch
//
//  Created by Vidushi Ojha on 5/22/15.
//  Copyright (c) 2015 Vidushi Ojha. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCircuitSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCircuitSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    let cropLayer = SKCropNode()
    let maskLayer = SKNode()
    
    var swipeHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode()
    
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
        gameLayer.hidden = true
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        gameLayer.addChild(cropLayer)
        
        maskLayer.position = layerPosition
        cropLayer.maskNode = maskLayer
        
        circuitsLayer.position = layerPosition
        cropLayer.addChild(circuitsLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
        SKLabelNode(fontNamed: "Courier")
        
    }
    
    func addSpritesForCircuits(circuits: Set<Circuit>) {
        for circuit in circuits {
            let sprite = SKSpriteNode(imageNamed: circuit.circuitType.spriteName)
            sprite.position = pointForColumn(circuit.column, row: circuit.row)
            circuitsLayer.addChild(sprite)
            circuit.sprite = sprite
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.runAction( SKAction.sequence([
                SKAction.waitForDuration(0.25, withRange: 0.5),
                SKAction.group([
                    SKAction.fadeInWithDuration(0.25),
                    SKAction.scaleTo(1.0, duration: 0.25)])
            ]) )
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
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    tileNode.position = pointForColumn(column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        for row in 0...NumRows {
            for column in 0...NumColumns {
                let topLeft     = (column > 0) && (row < NumRows)
                    && level.tileAtColumn(column - 1, row: row) != nil
                let bottomLeft  = (column > 0) && (row > 0)
                    && level.tileAtColumn(column - 1, row: row - 1) != nil
                let topRight    = (column < NumColumns) && (row < NumRows)
                    && level.tileAtColumn(column, row: row) != nil
                let bottomRight = (column < NumColumns) && (row > 0)
                    && level.tileAtColumn(column, row: row - 1) != nil

                let value = Int(topLeft) | Int(topRight) << 1 | Int(bottomLeft) << 2 | Int(bottomRight) << 3

                if value != 0 && value != 6 && value != 9 {
                    let name = String(format: "Tile_%ld", value)
                    let tileNode = SKSpriteNode(imageNamed: name)
                    var point = pointForColumn(column, row: row)
                    point.x -= TileWidth/2
                    point.y -= TileHeight/2
                    tileNode.position = point
                    tilesLayer.addChild(tileNode)
                }
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(circuitsLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            
            if let circuit = level.circuitAtColumn(column, row: row) {
                
                swipeFromColumn = column
                swipeFromRow = row
                showSelectionIndicatorForCircuit(circuit)
                
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
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
                hideSelectionIndicator()
                
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
        
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
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
        
        runAction(swapSound)
        
    }
    
    func showSelectionIndicatorForCircuit(circuit: Circuit) {
        
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = circuit.sprite {
            let texture = SKTexture(imageNamed: circuit.circuitType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
        
    }
    
    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence( [SKAction.fadeOutWithDuration(0.3), SKAction.removeFromParent()] ))
    }
    
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        
        let spriteA = swap.circuitA.sprite!
        let spriteB = swap.circuitB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence( [moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence( [moveB, moveA]) )
        
        runAction(invalidSwapSound)
        
    }
    
    func animateMatchedCircuits(chains: Set<Chain>, completion: ()->()) {
        
        for chain in chains {
            animateScoreForChain(chain)
            for circuit in chain.circuits {
                if let sprite = circuit.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence( [scaleAction, SKAction.removeFromParent()] ), withKey: "removing")
                    }
                }
            }
        }
        
        runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
        
    }
    
    func animateFallingCircuits(columns: [[Circuit]], completion: ()->()) {
        
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (indx, circuit) in array.enumerate() {
                let newPosition = pointForColumn(circuit.column, row: circuit.row)
                
                let delay = 0.05 + 0.15*NSTimeInterval(indx)
                
                let sprite = circuit.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y)/TileHeight) * 0.1)
                
                longestDuration = max(longestDuration, duration+delay)
                
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                
                sprite.runAction(SKAction.sequence( [SKAction.waitForDuration(delay), SKAction.group([moveAction, fallingCircuitSound])] ))
            }
        }
        
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
        
    }
    
    func animateNewCircuits(columns: [[Circuit]], completion: () -> ()) {
        
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            
            let startRow = array[0].row + 1
            
            for (idx, circuit) in array.enumerate() {
                
                let sprite = SKSpriteNode(imageNamed: circuit.circuitType.spriteName)
                sprite.position = pointForColumn(circuit.column, row: startRow)
                circuitsLayer.addChild(sprite)
                circuit.sprite = sprite
                
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                
                let duration = NSTimeInterval(startRow - circuit.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                
                let newPosition = pointForColumn(circuit.column, row: circuit.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            SKAction.fadeInWithDuration(0.05),
                            moveAction,
                            addCircuitSound])
                        ]))
            }
        }
        
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    func animateScoreForChain(chain: Chain) {
        let firstSprite = chain.firstCircuit().sprite!
        let lastSprite = chain.lastCircuit().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%1d", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        circuitsLayer.addChild(scoreLabel)
        
        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .EaseOut
        scoreLabel.runAction(SKAction.sequence( [moveAction, SKAction.removeFromParent()] ))
    }
    
    func animateGameOver(completion: ()->()) {
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseOut
        gameLayer.runAction(action, completion: completion)
    }
    
    func animateBeginGame(completion: ()->()) {
        gameLayer.hidden = false
        gameLayer.position = CGPoint(x: 0, y: size.height)
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseOut
        gameLayer.runAction(action, completion: completion)
    }
    
    func removeALlCircuitSprites() {
        circuitsLayer.removeAllChildren()
    }
    
}






























