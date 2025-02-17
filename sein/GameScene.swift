import SpriteKit
import UIKit

class GameScene: SKScene {
    var waterButton: SKSpriteNode!  // Top-right button
    var rainNode: SKEmitterNode?   // Rain particle
    var treeWaterDrops: [SKSpriteNode] = []  // Stores tree buttons
    var trees: [SKSpriteNode] = []  // Stores tree nodes

    override func didMove(to view: SKView) {
        // Set background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
        
        // Tree images
        let treeImages = ["mango1", "magyi2", "magyi1", "magyi3", "mango3", "mango1", "magyi3", "magyi3"]
        
        // Tree positions
        let treePositions = [
            CGPoint(x: size.width * 0.1, y: size.height * 0.7),
            CGPoint(x: size.width * 0.15, y: size.height * 0.3),
            CGPoint(x: size.width * 0.3, y: size.height * 0.73),
            CGPoint(x: size.width * 0.4, y: size.height * 0.3),
            CGPoint(x: size.width * 0.5, y: size.height * 0.65),
            CGPoint(x: size.width * 0.6, y: size.height * 0.35),
            CGPoint(x: size.width * 0.85, y: size.height * 0.7),
            CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        ]
        
        for (index, position) in treePositions.enumerated() {
            let tree = createTreeNode(named: treeImages[index], at: position)
            tree.name = treeImages[index]
            addChild(tree)
            trees.append(tree)
        }
        
        // Add water drop button (Top-right corner)
        waterButton = SKSpriteNode(imageNamed: "waterdrop")
        waterButton.name = "waterButton"
        waterButton.size = CGSize(width: size.width * 0.09, height: size.width * 0.07)
        waterButton.position = CGPoint(x: size.width - waterButton.size.width / 2 - 10, y: size.height - waterButton.size.height / 1.5 - 10)
        waterButton.zPosition = 1
        addChild(waterButton)
    }
    
    func createTreeNode(named imageName: String, at position: CGPoint) -> SKSpriteNode {
        let tree = SKSpriteNode(imageNamed: imageName)
        tree.position = position
        tree.size = CGSize(width: size.width * 0.2, height: size.width * 0.2)
        tree.isUserInteractionEnabled = false
        return tree
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode == waterButton {
            showTreeWaterDropButtons()
        } else if let touchedWaterDrop = touchedNode as? SKSpriteNode, treeWaterDrops.contains(touchedWaterDrop) {
            if let index = treeWaterDrops.firstIndex(of: touchedWaterDrop) {
                let tree = trees[index]
                startRainEffect(over: tree)
            }
        }
    }
    
    func showTreeWaterDropButtons() {
        treeWaterDrops.forEach { $0.removeFromParent() }
        treeWaterDrops.removeAll()
        
        for tree in trees {
            let waterDropButton = SKSpriteNode(imageNamed: "waterdrop")
            waterDropButton.size = CGSize(width: tree.size.width * 0.3, height: tree.size.height * 0.3)
            waterDropButton.position = CGPoint(x: tree.position.x, y: tree.position.y + (tree.size.height * 0.55))
            waterDropButton.zPosition = 2
            waterDropButton.name = "waterDrop_\(tree.name!)"
            addChild(waterDropButton)
            treeWaterDrops.append(waterDropButton)
        }
    }
    
    func startRainEffect(over tree: SKSpriteNode) {
        rainNode?.removeFromParent()
        
        if let rain = SKEmitterNode(fileNamed: "MyParticle") {
            let startOffset = tree.size.height * 0.2
            let rainStartY = tree.position.y + (tree.size.height / 1.3) - startOffset
            let endOffset = tree.size.height * 0.1
            let fallDistance = tree.size.height - startOffset - endOffset
            
            rain.position = CGPoint(x: tree.position.x, y: rainStartY)
            let fallTime = 1.2
            rain.particleLifetime = fallTime
            rain.particleLifetimeRange = 0
            rain.particleSpeed = fallDistance / fallTime
            rain.yAcceleration = 0
            rain.particlePositionRange.dx = tree.size.width
            rain.zPosition = 3
            addChild(rain)
            rainNode = rain
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.run {
                    rain.removeFromParent()
                    self.updateTree(tree)
                }
            ]))
        }
    }
    
    func updateTree(_ tree: SKSpriteNode) {
        guard let currentName = tree.name else { return }
        
        // Extract the prefix (letters) and suffix (numbers)
        let letters = currentName.prefix { $0.isLetter }
        let numbers = currentName.drop { $0.isLetter }
        
        if let number = Int(numbers) {
            let newNumber = number + 1
            let newName = "\(letters)\(newNumber)"
            
            // Check if the new texture exists before applying it
            let newTexture = SKTexture(imageNamed: newName)
            tree.texture = newTexture
            tree.name = newName
        }
    }
}
