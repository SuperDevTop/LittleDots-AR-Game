import Foundation
import SceneKit
import UIKit

struct ConnectDotsGameLevel {
    var number: Int
    var image: UIImage?
    var dots: [ConnectDotsGameDot]
    var scale: CGFloat
}

struct ConnectDotsGameDot {
    var name: String
    var color: UIColor
}

enum levelProgress {
    case done
    case incomplete
    case locked
}

let colorValues = [
    UIColor(red: 0.8902, green: 0.5255, blue: 0.5137, alpha: 1),
    UIColor(red: 0.8745, green: 0.6980, blue: 0.3490, alpha: 1),
    UIColor(red: 0.5216, green: 0.9490, blue: 0.4745, alpha: 1),
    UIColor(red: 0.4314, green: 0.6667, blue: 0.8980, alpha: 1),
    UIColor(red: 0.5412, green: 0.3922, blue: 0.8235, alpha: 1)
]
class LevelData {
    var levels = [
        ConnectDotsGameLevel(
            number: 3,
            image: UIImage(named: "level1CompleteImage.png"),
            dots: [
                ConnectDotsGameDot(
                    name: "1",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "2",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "3",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "4",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "5",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "6",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "7",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "8",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "9",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "10",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "11",
                    color: colorValues[0]
                ),
            ],
            scale: 8
        ),
        ConnectDotsGameLevel(
            number: 2,
            image: UIImage(named: "level2CompleteImage.png"),
            dots: [
                ConnectDotsGameDot(
                    name: "1",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "2",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "3",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "4",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "5",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "6",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "7",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "8",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "9",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "10",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "11",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "12",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "13",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "14",
                    color: colorValues[3]
                ),
                 ConnectDotsGameDot(
                    name: "15",
                    color: colorValues[4]
                ),
                 ConnectDotsGameDot(
                    name: "16",
                    color: colorValues[0]
                ),
            ],
            scale: 15
        ),
        ConnectDotsGameLevel(
            number: 1,
            image: UIImage(named: "level3CompleteImage.png"),
            dots: [
                ConnectDotsGameDot(
                    name: "1",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "2",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "3",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "4",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "5",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "6",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "7",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "8",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "9",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "10",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "11",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "12",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "13",
                    color: colorValues[2]
                )
            ],
            scale: 10
        ),
        ConnectDotsGameLevel(
            number: 4,
            image: UIImage(named: "level4CompleteImage.png"),
            dots: [
                ConnectDotsGameDot(
                    name: "1",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "2",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "3",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "4",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "5",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "6",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "7",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "8",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "9",
                    color: colorValues[3]
                ),
                ConnectDotsGameDot(
                    name: "10",
                    color: colorValues[4]
                ),
                ConnectDotsGameDot(
                    name: "11",
                    color: colorValues[0]
                ),
                ConnectDotsGameDot(
                    name: "12",
                    color: colorValues[1]
                ),
                ConnectDotsGameDot(
                    name: "13",
                    color: colorValues[2]
                ),
                ConnectDotsGameDot(
                    name: "14",
                    color: colorValues[3]
                ),
                 ConnectDotsGameDot(
                    name: "15",
                    color: colorValues[4]
                ),
                 ConnectDotsGameDot(
                    name: "16",
                    color: colorValues[0]
                ),
            ],
            scale: 10
        )
    ]
    
    func loadModel(_ level: ConnectDotsGameLevel) -> CameraViewNodeProtocol {
        let levelName = "Level" + String(level.number) + ".scn"
        let scene = SCNScene(named: levelName)
        let node = SCNNode()
        let nodeName = "Model"

        if let modelNode = scene?.rootNode.childNode(withName: nodeName, recursively: true){
           modelNode.geometry?.firstMaterial?.isDoubleSided = true
           modelNode.geometry?.firstMaterial?.lightingModel = .physicallyBased
           node.addChildNode(modelNode)
        } else {
            log.error("Node couldn't be loaded")
        }
        return node
    }
    
    func loadAnimation(_ level: ConnectDotsGameLevel) -> CameraViewNodeProtocol {
        let levelName = "Level" + String(level.number) + ".scn"
        let scene = SCNScene(named: levelName)
        let nodeName = "Animation"
        let node = SCNNode()
        
        if let animationNode = scene?.rootNode.childNode(withName: nodeName, recursively: true){
            node.addChildNode(animationNode)
        } else {
            log.error("Animation node couldn't be loaded")
        }
        return node
    }
    
    func getParticleSystemPosition(_ level: ConnectDotsGameLevel) -> Vector {
        let levelName = "Level" + String(level.number) + ".scn"
        let scene = SCNScene(named: levelName)
        let nodeName = "ParticleSystemPosition"
        var position = SCNVector3(0)
        
        if let particleSystemNode = scene?.rootNode.childNode(withName: nodeName, recursively: true){
            position = particleSystemNode.worldPosition
        } else {
            log.error("Particle system node couldn't be loaded")
        }
        return position
    }
    
    func getAnimationMaterial(_ level: ConnectDotsGameLevel) -> SCNMaterial {
        let levelName = "Level" + String(level.number) + ".scn"
        let scene = SCNScene(named: levelName)
        let nodeName = "AnimationMaterial"
        var material = SCNMaterial()
        
        if let materialNode = scene?.rootNode.childNode(withName: nodeName, recursively: true),
            let foundMaterial = materialNode.geometry?.firstMaterial{
            material = foundMaterial
        } else {
            log.error("Animation material node couldn't be loaded")
        }
        return material
    }
}
let levelData = LevelData()
