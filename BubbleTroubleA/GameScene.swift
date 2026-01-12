//
//  GameScene.swift
//  BubbleTroubleA
//
//  Created by Weerawut on 12/1/2569 BE.
//

import SpriteKit

class GameScene: SKScene {
    var bubbleTextures = [SKTexture]()
    var currentBubbleTexture = 0
    var maximumNumber = 1
    var bubbles = [SKSpriteNode]()
    var bubbleTimer: Timer?
    
    override func didMove(to view: SKView) {
        bubbleTextures.append(SKTexture(imageNamed: "bubbleBlue"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleCyan"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleGray"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleGreen"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleOrange"))
        bubbleTextures.append(SKTexture(imageNamed: "bubblePink"))
        bubbleTextures.append(SKTexture(imageNamed: "bubblePurple"))
        bubbleTextures.append(SKTexture(imageNamed: "bubbleRed"))
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.gravity = CGVector.zero
        
        bubbleTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] timer in
            self?.createBubble()
        })
    }
    
    override func mouseDown(with event: NSEvent) {
        let loation = event.location(in: self)
        let clickNodes = self.nodes(at: loation).filter({$0.name != nil})
        guard clickNodes.count != 0 else { return }
        
        let lowestBubble = bubbles.min { Int($0.name!)! < Int($1.name!)!}
        guard let bestNumber = lowestBubble?.name else { return }
        
        for node in clickNodes {
             if node.name == bestNumber {
                pop(node as! SKSpriteNode)
                return
            }
        }
        
        createBubble()
        createBubble()
    }
    
    func createBubble() {
        let bubble = SKSpriteNode(texture: bubbleTextures[currentBubbleTexture])
        bubble.name = String(maximumNumber)
        bubble.zPosition = 1
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        label.text = bubble.name
        label.color = NSColor.white
        label.fontSize = 64
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        
        bubble.addChild(label)
        addChild(bubble)
        bubbles.append(bubble)
        
        let xPos = Int.random(in: 0..<800)
        let yPos = Int.random(in: 0..<600)
        bubble.position = CGPoint(x: CGFloat(xPos), y: CGFloat(yPos))
        
        let scale = Double.random(in: 0...1)
        bubble.setScale(max(0.7,scale))
        
        bubble.alpha = 0
        bubble.run(SKAction.fadeIn(withDuration: 0.5))
        
        configurePhysics(for: bubble)
        nextBubble()
    }
    
    func nextBubble() {
        currentBubbleTexture += 1
        if currentBubbleTexture == bubbleTextures.count {
            currentBubbleTexture = 0
        }
        
        maximumNumber += Int.random(in: 1...3)
        let stringMaximumNumber = String(maximumNumber)
        if stringMaximumNumber.last! == "6" {
            maximumNumber += 1
        }
        if stringMaximumNumber.last! == "9" {
            maximumNumber += 1
        }
    }
    
    func configurePhysics(for bubble: SKSpriteNode) {
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: bubble.size.width/2)
        bubble.physicsBody?.linearDamping = 0.0
        bubble.physicsBody?.angularDamping = 0.0
        bubble.physicsBody?.restitution = 1.0
        bubble.physicsBody?.friction = 0.0
        
        let motionX = Double.random(in: -200...200)
        let motionY = Double.random(in: -200...200)
        bubble.physicsBody?.velocity = CGVector(dx: motionX, dy: motionY)
        bubble.physicsBody?.angularVelocity = Double.random(in: 0...1)
    }
    
    func pop(_ node: SKSpriteNode) {
        guard let index = bubbles.firstIndex(of: node) else { return }
        bubbles.remove(at: index)
        
        node.physicsBody = nil
        node.name = nil
        
        run(SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false))
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleUp = SKAction.scale(by: 1.5, duration: 0.3)
        scaleUp.timingMode = .easeOut
        let group = SKAction.group([fadeOut,scaleUp])
        let sequence = SKAction.sequence([group,SKAction.removeFromParent()])
        node.run(sequence)
        
        if bubbles.count == 0 {
            showGameOverText()
            bubbleTimer?.invalidate()
        }
    }
    
    func showGameOverText() {
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        label.text = "Game Over!"
        label.color = NSColor.white
        label.fontSize = 64
        label.verticalAlignmentMode = .center
        label.zPosition = 2
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        addChild(label)
    }
}
