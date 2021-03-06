//
//  GameScene.swift
//  TapTapBuuf
//
//  Created by Nathan Sowder on 4/10/16.
//  Copyright (c) 2016 Nathan Sowder. All rights reserved.
//

import SpriteKit

struct PhysicsCatagory {
    static let Bird : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4


}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Bird = SKSpriteNode()
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    
    let scoreLabel = SKLabelNode()
    
    var died = Bool()
    
    var restartBtn = SKSpriteNode()
    
    
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        
        died = false
        gameStarted = false
        score = 0
        createScene()
        
        
    }
    
    func createScene(){
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
            self.addChild(background)
        }
        
        
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        scoreLabel.fontName = "Go Boom!"
        scoreLabel.fontSize = 60
        scoreLabel.zPosition = 6
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.Bird
        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Bird
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        
        self.addChild(Ground)
        
        
        
        Bird = SKSpriteNode(imageNamed: "Bird")
        Bird.size = CGSize(width: 60, height: 70)
        Bird.position = CGPoint(x: self.frame.width / 2 - Bird.frame.width, y: self.frame.height / 2)
        
        
        Bird.physicsBody = SKPhysicsBody(circleOfRadius: Bird.frame.height / 2)
        Bird.physicsBody?.categoryBitMask = PhysicsCatagory.Bird
        Bird.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall
        Bird.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
        Bird.physicsBody?.affectedByGravity = false
        Bird.physicsBody?.isDynamic = true
        
        Bird.zPosition = 2
        
        
        self.addChild(Bird)

        
        
        
    }
    override func didMove(to view: SKView) {
        
        createScene()
        
        }
    
    
    
    func creatBtn(){
        
        restartBtn = SKSpriteNode(imageNamed: "RestartBtn")
        restartBtn.size = CGSize(width: 200, height: 100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 7
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.2))
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Bird {
            
            score += 1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
            
            
            
        }
        
        else if firstBody.categoryBitMask == PhysicsCatagory.Bird && secondBody.categoryBitMask == PhysicsCatagory.Score {
            
            score += 1
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
            
            
        }
        
        
        if firstBody.categoryBitMask == PhysicsCatagory.Bird && secondBody.categoryBitMask == PhysicsCatagory.Wall || firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Bird{
       
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false{
                died = true
                creatBtn()
            }
            
        
        
        
        }
        
    
        
        if firstBody.categoryBitMask == PhysicsCatagory.Bird && secondBody.categoryBitMask == PhysicsCatagory.Ground || firstBody.categoryBitMask == PhysicsCatagory.Ground && secondBody.categoryBitMask == PhysicsCatagory.Bird{
            
            
            enumerateChildNodes(withName: "wallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions()
            }))
            if died == false{
                died = true
                creatBtn()
            }

        }
        
        
        
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
            
            gameStarted = true
            
            Bird.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                () in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.wait(forDuration: 1.5)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let moveWalls = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.008 * distance))
            let removeWalls = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([moveWalls, removeWalls])

            
            Bird.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            Bird.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 90))
        }
        else{
            
            if died == true{
                
                
            }
            else{
            
                Bird.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
                Bird.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 90))
        
        }
        
        
        }
        
        
        for touch in touches {
           let location = touch.location(in: self)
            
            if died == true{
                
                if restartBtn.contains(location){
                    restartScene()
                }
                
                
            }
            
        }
        
        
        
        
        
        
        
        
        
        
    }
   
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "Arg")
        
        scoreNode.size = CGSize(width:50, height: 50)
        
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Bird
        
        
        
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2  + 350)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2  - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Bird
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Bird
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCatagory.Bird
        btmWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Bird
        btmWall.physicsBody?.affectedByGravity = false
        btmWall.physicsBody?.isDynamic = false

        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
        
        
        
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
    
    
    }
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: ({
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                        
                    }
                    
                }))
                
            }
            
            
        }
        
        
        
        
    }

}
