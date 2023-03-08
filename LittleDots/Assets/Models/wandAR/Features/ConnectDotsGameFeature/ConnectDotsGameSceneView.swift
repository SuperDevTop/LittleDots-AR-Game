import SceneKit

fileprivate func getWrongBalloonNode(for number : String, onComplete :(()->Void)?) -> SCNNode {
    let wrongBalloon = SCNNode()
    wrongBalloon.name = "wrongBalloonAnimation"
    let testScene = SCNScene(named: "art.scnassets/BalloonWrongAnimation.scn")
    guard let loadedTestScene = testScene else {
        log.error("Wrong balloon animation did not load")
        return SCNNode()
    }
    for testChildNode in loadedTestScene.rootNode.childNodes {
        wrongBalloon.addChildNode(testChildNode as SCNNode)
    }
    
    if let balloon = wrongBalloon.childNodes.first?.childNodes.first {
        if let animationPlayer = balloon.animationPlayer(forKey: balloon.animationKeys.first!) {
            let animation = animationPlayer.animation
            animation.usesSceneTimeBase = false
            animation.repeatCount = 0
            animation.duration = 3.3333
            animation.animationDidStop = { (animation, reciever, completed) in
                onComplete?()
            }
            balloon.geometry?.firstMaterial?.diffuse.contents = UIImage(named: number + ".png")
        }
    }
    wrongBalloon.scale = SCNVector3(0.05, 0.05, 0.05)
    let wrongBalloonWrapper = SCNNode()
    
    wrongBalloonWrapper.addChildNode(wrongBalloon)
    return wrongBalloonWrapper
    //        return wrongBalloon
}

fileprivate func popBackAnimation(for node: SCNNode, onComplete: (() -> Void)?){
        let wrongQueue = AnimationQueue()
    let appear = CAKeyframeAnimation(keyPath: "scale")
    let easeIn  = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
    appear.values   = [SCNVector3(0.000), SCNVector3(0.02), SCNVector3(0.018), SCNVector3(0.015)]
    appear.duration = 2
    appear.keyTimes = [0.000000, 0.5, 0.75, 1]
    appear.timingFunction = easeIn
    appear.delegate = wrongQueue
    node.addAnimation(appear, forKey: "Scale")
    node.scale = SCNVector3(0.015)
    wrongQueue.append {
        onComplete?()
    }
}

class ConnectDotsGameSceneView {
    var currentGameNode: SCNNode?
    var levelNode = SCNNode()
    var cameraNode: CameraLogicProtocol?
    var balloonNode =  SCNNode()
    let linesNode = SCNNode()
    var currentGameModelAnimation = SCNNode()
    // 1. To anchor the model and dots to the same point
    var anchorPosition: Vector?
    var anchorAngle: Vector?
    // 2. For drawing lines
    var firstPoint: Vector?
    var secondPoint: Vector?
    // 3. Animating
    var mainGameplayAnimationQueue = AnimationQueue()
    var failAnimationQueue = AnimationQueue()
    
    init () {
        loadBalloonGeometery()
    }
    
    // MARK: Functions called from game view
    func loadInCompleteLevel(number level: ConnectDotsGameLevel, camera: CameraLogicProtocol, progress: Int) {
        cleanSceneView()
        // Setting the starting and ending points for the line drawing null
        firstPoint = nil
        secondPoint = nil
        cameraNode =  camera
      //  var gameNode = self.getLevelNode(for: level)
        var gameNode = levelNode
        gameNode = self.orientNode(node: gameNode)
        cameraNode?.addNode(gameNode)
        cameraNode?.addNode(linesNode)
        currentGameNode = gameNode
        currentGameNode?.name = String(level.number)
        anchorPosition = gameNode.worldPosition
        anchorAngle = gameNode.eulerAngles
        if progress > 0 {
            self.loadProgress(for: level, till: progress)
        }
    }
    
    func loadCompleteLevel(number level: ConnectDotsGameLevel, camera: CameraLogicProtocol) {
        anchorAngle = nil
        anchorPosition = nil
        cameraNode = camera
        addModel(for: level) {}
    }
    
    func balloonSuccessAnimation(node: SCNNode, onCompelte: (()-> Void)?) {
        let testScene = SCNScene(named: "art.scnassets/BalloonRightAnimation.scn")
        guard let balloonNode = testScene?.rootNode.childNode(withName: "Balloon", recursively: false) else {
            log.error("Right balloon node not found")
            return
        }
        guard let animationKey = balloonNode.childNodes.first?.animationKeys.first,
            let animationPlayer =  balloonNode.childNodes.first?.animationPlayer(forKey: animationKey) else {
                log.error("No animation found")
                return
        }
        let animation = animationPlayer.animation
        animation.usesSceneTimeBase = false
        animation.animationDidStop = { _, _, _ in
            onCompelte?()
        }
        animation.repeatCount = 0
        animation.duration = 0.292
        node.addAnimation(animation, forKey: "Complete")
    }
    
    func completeDot(_ dot: ConnectDotsGameDot) {
        guard let nodeFound = self.findNodeForDot(dot) else {
            log.error("No node for dot")
            return
        }
        guard let balloonNode = nodeFound.childNode(withName: "Balloon", recursively: true) else {
            log.error("Sub-node not found in node")
            return
        }
        balloonSuccessAnimation(node: balloonNode, onCompelte: {
            balloonNode.removeFromParentNode()
            let confettiNode = ConfettiNode()
            confettiNode.particleSystems?.first?.particleColor = dot.color
            nodeFound.addChildNode(confettiNode)
            self.addNumbers(Int(dot.name)!, position: nodeFound.worldPosition, color: dot.color)
        })
       // Selecting the current and the previous points to be used to draw lines
        if firstPoint == nil {
            firstPoint = nodeFound.worldPosition
        } else {
            if secondPoint == nil {
                secondPoint = nodeFound.worldPosition
            } else {
                firstPoint = secondPoint
                secondPoint = nodeFound.worldPosition
            }
        }
        if let first = firstPoint, let second = secondPoint {
            let node = SCNNode.makeline(from: first, to: second, radius: config.connectGameSceneParameters.connectingLineRadius, color: .white)
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            if !mainGameplayAnimationQueue.isAnimating && mainGameplayAnimationQueue.isEmpty() {
                mainGameplayAnimationQueue.isAnimating = true
                addLineAnimation(to: node)
            } else {
                node.scale.y = 0
                mainGameplayAnimationQueue.append{
                    self.addLineAnimation(to: node)
                }
            }
            linesNode.addChildNode(node)
        }
        
    }
    
    func failAt(node: CameraViewNodeProtocol, isLevelOver: Bool, onComplete: (() -> Void)?) {
        guard let currentNode = node as? SCNNode else {
            log.error("No balloon node found in node")
            return
        }
        guard let camera = cameraNode, var cameraTransform = camera.cameraTransform else {
            log.error("Camera Transform not found")
            return
        }
        popNode(currentNode)
        if let nodeName = node.name {
            let wrongBalloonNode = getWrongBalloonNode(for: nodeName, onComplete: {
                if !isLevelOver {
                    onComplete?()
                    self.popBackNode(for: currentNode, onComplete: {})
                } else {
                    onComplete?()
                }
            })
            currentGameNode?.addChildNode(wrongBalloonNode)
            wrongBalloonNode.worldPosition = node.worldTransform.positionVector()
            cameraTransform.m42 = wrongBalloonNode.worldPosition.y
            wrongBalloonNode.look(at: cameraTransform.positionVector())
        }
    }

    func levelComplete(_ currentLevel: ConnectDotsGameLevel, onComplete: @escaping (() -> Void)) {
        let node = getLastLine(currentLevel)
        DispatchQueue.global(qos: .background).async {
            self.currentGameModelAnimation = self.getModelAnimation(for: currentLevel, onComplete: {
                self.addModel(for: currentLevel, onComplete: {
                    let confettiNode = BigConfettiNode()
                    confettiNode.position = levelData.getParticleSystemPosition(currentLevel)
                    self.currentGameNode?.addChildNode(confettiNode)
                    onComplete()
                })
            })
        }
        if !mainGameplayAnimationQueue.isAnimating && mainGameplayAnimationQueue.isEmpty() {
            mainGameplayAnimationQueue.isAnimating = true
            addLineAnimation(to: node)
        } else {
            node.scale.y = 0
            mainGameplayAnimationQueue.append{
                self.addLineAnimation(to: node)
            }
        }
        self.mainGameplayAnimationQueue.append{
            self.addModelAnimation(for: currentLevel)
        }
    }
    
    func popBackNode(for node: SCNNode, onComplete: (() -> Void)?){
        guard let name = node.name else {
            log.error("No name for the node found")
            return
        }
        let balloonNode = createNodeFrom(dotName: name)
        balloonNode.scale = SCNVector3(0)
        balloonSpawnAnimation(node: balloonNode, onCompelte: {
            balloonNode.scale = SCNVector3(1)
        })
        node.addChildNode(balloonNode)
    }
    
    func show() {
        // All default scene elements (if any)
    }
    
    func hide() {
        self.cleanSceneView()
    }
    
    func cleanSceneView() {
        self.clearGameNode()
        if let gameNode = currentGameNode {
            gameNode.removeFromParentNode()
        }
        linesNode.removeFromParentNode()
        self.anchorPosition = nil
        self.anchorAngle = nil
        self.mainGameplayAnimationQueue.isAnimating = false
        self.mainGameplayAnimationQueue = AnimationQueue()
    }
    
    func activateHighlightingDot(_ dot: ConnectDotsGameDot) {
        guard let nodeFound = self.currentGameNode?.childNode(
            withName: dot.name, recursively: true) else {
                log.error("No scene node found for activating dot")
                return
        }
        guard let balloonNode = nodeFound.childNode(withName: "Balloon", recursively: true) else {
           // log.error("Sub-node not found in node")
            return
        }
        balloonNode.runAction(SCNAction.fadeOpacity(
            to: config.connectGameSceneParameters.touchingDotOpacity,
            duration: Double(config.connectGameSceneParameters.fadeInDotDuration)))
    }
    
    func deactivateHighlightingDot(_ dot: ConnectDotsGameDot) {
        guard let nodeFound = self.findNodeForDot(dot) else {
            log.error("No scene node found for activating dot")
            return
        }
        guard let balloonNode = nodeFound.childNode(withName: "Balloon", recursively: true) else {
         //   log.error("No balloon node found in node")
            return
        }
        balloonNode.runAction(SCNAction.fadeOpacity(
            to: config.connectGameSceneParameters.nonTouchingDotOpacity,
            duration: Double(config.connectGameSceneParameters.fadeInDotDuration)))
    }

    func isDotInProximity(_ cameraWorldTransform: Transform,_ dot: ConnectDotsGameDot) -> Bool? {
        if let node = self.findNodeForDot(dot) {
            return isNodeInProximity(cameraWorldTransform, node.worldTransform)
        }
        return nil
    }
    
    func isNodeInProximity(_ cameraWorldTransform: Transform,_ nodeWorldTransform: Transform) -> Bool {
        let d = nodeWorldTransform.distance(from: cameraWorldTransform)
        return d < Float(config.connectGameSceneParameters.dotProximityDistance)
    }
    
    // MARK: Helper functions
    
    func prepareLevelNode(for level: ConnectDotsGameLevel) {
        self.levelNode = getLevelNode(for: level)
    }
    
    private func getLevelNode(for level: ConnectDotsGameLevel) -> SCNNode {
        let levelNode = SCNNode()
        let dotsNode = SCNNode()
        dotsNode.name = "dots"
        let scene = SCNScene(named: "Level" + String(level.number) + ".scn")
        levelNode.addChildNode(dotsNode)
        for dot in level.dots {
            guard let node = scene?.rootNode.childNode(withName: dot.name, recursively: true) else {
                log.error("Point Node not found")
                return SCNNode()
            }
            let dotNode = SCNNode()
            let balloonNode = createNodeFrom(dotName: dot.name)
            dotNode.scale = SCNVector3(Float(level.scale) * 0.015)
            dotNode.eulerAngles.x = -Float.pi/2
            dotNode.eulerAngles.y = -0.52
            dotNode.name = dot.name
            dotNode.addChildNode(balloonNode)
            dotNode.position = node.worldPosition
            balloonSpawnAnimation(node: balloonNode, onCompelte: {})
            dotsNode.addChildNode(dotNode)
        }
        dotsNode.scale = SCNVector3((1/level.scale),(1/level.scale),(1/level.scale))
        return levelNode
    }
    
    private func createNodeFrom(dotName: String) -> SCNNode {
        let balloon = SCNNode()
        balloon.transform = balloonNode.transform
        balloon.geometry = balloonNode.geometry?.copy() as? SCNGeometry
        balloon.geometry?.firstMaterial = SCNMaterial()
        balloon.geometry?.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
        balloon.geometry?.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
        balloon.geometry?.firstMaterial?.lightingModel = .physicallyBased
        balloon.name = "Balloon"
        balloon.opacity = config.connectGameSceneParameters.nonTouchingDotOpacity
        balloon.geometry?.firstMaterial?.diffuse.contents = UIImage(named: dotName + ".png")
        return balloon
    }

    private func loadBalloonGeometery() {
        let scene = SCNScene(named: "BalloonUV.scn")
        guard let balloonNode = scene?.rootNode.childNode(withName: "Balloon", recursively: false) else {
            log.error("Balloon Node not found")
            return
        }
        self.balloonNode = balloonNode
    }
    
    func balloonSpawnAnimation(node: SCNNode, onCompelte: (()-> Void)?) {
        let testScene = SCNScene(named: "art.scnassets/BalloonSpawn.scn")
        guard let balloonNode = testScene?.rootNode.childNode(withName: "Balloon", recursively: false) else {
            log.error("Spawn balloon node not found")
            return
        }
        guard let animationKey = balloonNode.childNodes.first?.animationKeys.first,
            let animationPlayer =  balloonNode.childNodes.first?.animationPlayer(forKey: animationKey) else {
                log.error("No animation found")
                return
        }
        let animation = animationPlayer.animation
        animation.usesSceneTimeBase = false
        animation.animationDidStop = { _, _, _ in
            onCompelte?()
        }
        animation.repeatCount = 0
        animation.duration = 0.417
        node.addAnimation(animation, forKey: "Spawn")
    }
    
    private func clearGameNode() {
        // Clean the game Node
        if let gameNode = currentGameNode {
            for node in gameNode.childNodes {
                node.removeFromParentNode()
            }
        }
        for line in linesNode.childNodes{
            line.removeFromParentNode()
        }
    }
    
    private func orientNode(node : SCNNode) -> SCNNode {
        guard let camera = cameraNode, var cameraTransform = camera.cameraTransform else {
                log.error("Camera Transform not found")
                return SCNNode()
        }
        let tempTransform = cameraTransform.multiply(Transform().translate(0, 0, -config.connectGameSceneParameters.gameCameraOffset))
        node.position = tempTransform.positionVector()
        // For the node .look function to not rotate the object in any other axis but y axis, "translating" the camera position to the position of the node to turn
        cameraTransform.m42 = node.worldPosition.y
        node.look(at: cameraTransform.positionVector())
        return node
    }
    
    private func loadProgress(for level: ConnectDotsGameLevel, till dotCompleted: Int) {
        guard dotCompleted > 1 else {
            log.verbose("No progress to load")
            return
        }
        var pointOne: Vector? = nil
        var pointTwo: Vector? = nil
        log.verbose("Loading progress")
        for i in 1...dotCompleted - 1 {
            if let dot = level.dots.first(where: { $0.name == String(i)}){
                guard let nodeFound = self.findNodeForDot(dot) else {
                    log.error("No scene node found for activating dot")
                    return
                }
                self.popNode(nodeFound)
                self.addNumbers(i, position: nodeFound.worldPosition, color: dot.color)
                if pointOne == nil {
                    pointOne = nodeFound.worldPosition
                } else {
                    if pointTwo == nil {
                        pointTwo = nodeFound.worldPosition
                    } else {
                        pointOne = pointTwo
                        pointTwo = nodeFound.worldPosition
                    }
                }
                if let first = pointOne, let second = pointTwo {
                    let node = SCNNode.makeline(from: first, to: second,
                                                radius: config.connectGameSceneParameters.connectingLineRadius, color: .white)
                    node.geometry?.firstMaterial?.lightingModel = .physicallyBased
                    linesNode.addChildNode(node)
                }
            } else {
                log.error("Node not found")
            }
        }
        self.firstPoint = pointOne
        self.secondPoint = pointTwo
    }
    
    private func findNodeForDot(_ dot: ConnectDotsGameDot) -> SCNNode? {
        return self.currentGameNode?.childNode(withName: dot.name, recursively: true)
    }
    
    private func popNode(_ nodeFound: SCNNode) {
        guard let balloonNode = nodeFound.childNode(withName: "Balloon", recursively: true) else {
            log.error("No balloon node found in node")
            return
        }
        balloonNode.removeFromParentNode()
    }
    
    private func addNumbers(_ number: Int, position: Vector, color: UIColor) {
        let scene = SCNScene(named: "Numbers.dae")
        guard let number = scene?.rootNode.childNode(withName: "_" + String(number), recursively: false) else {
            log.error("Number Node not found")
            addSphere(position: position, color: color)
            return
        }
        guard let camera = self.cameraNode,
            var cameraTransform = camera.cameraTransform else {
                log.error("Camera not initialized")
                return
        }
        log.verbose("Added node for number:\(number)")
        currentGameNode?.addChildNode(number)
        number.name = "Number = \(number)"
        number.scale = SCNVector3(0.05,0.05,0.05)
        number.geometry?.firstMaterial?.diffuse.contents = color
        number.geometry?.firstMaterial?.lightingModel = .physicallyBased
        number.worldPosition = position
        cameraTransform.m42 = number.worldPosition.y
        number.look(at: cameraTransform.positionVector(), up: SCNVector3(0,1,0), localFront: SCNVector3(0,0,1))
    }
    
    private func addLineAnimation(to node: SCNNode) {
        node.scale.y = 1
        guard let cylinder = node.geometry as? SCNCylinder else {
            log.error("Node geometery not a cylinder")
            return
        }
        let height = Double(cylinder.height)
        let appear = CAKeyframeAnimation(keyPath: "scale.y")
        let easeIn  = CAMediaTimingFunction(controlPoints: 0.47, 0, 0.745, 0.715)
        appear.delegate = mainGameplayAnimationQueue
        appear.values   = [0.000000, 1.0000]
        appear.keyTimes = [0.000000, 1.0000]
        appear.timingFunction = easeIn
        appear.duration = height * 5
        node.addAnimation(appear, forKey: "appear")
    }
    
    private func getLastLine(_ currentLevel: ConnectDotsGameLevel) -> SCNNode {
        guard let firstDot = currentLevel.dots.first, let lastDot = currentLevel.dots.last else {
            log.error("Dots not found")
            return SCNNode()
        }
        guard let first = findNodeForDot(firstDot) else {
            log.error("First point node not found")
            return SCNNode()
        }
        guard let last = findNodeForDot(lastDot) else {
            log.error("Last point node not found")
            return SCNNode()
        }
        
        let node = SCNNode.makeline(from: last.worldPosition, to: first.worldPosition,
                                    radius: config.connectGameSceneParameters.connectingLineRadius, color: .white)
        node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        linesNode.addChildNode(node)
        return node
    }
    
    private func getModel(for level: ConnectDotsGameLevel) -> SCNNode{
        let modelNode = levelData.loadModel(level)
        guard var node = modelNode as? SCNNode else {
            log.error("Model node not conforming to SCNNode")
            return SCNNode()
        }
        log.verbose("Model loaded")
        node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        if let position = anchorPosition, let angle = anchorAngle  {
            // In case there is already an anchor to place the objects at
            node.worldPosition = position
            node.eulerAngles = angle
        } else {
            // Will change this to only changing the position of the object
            node = self.orientNode(node: node)
        }
        node.scale = SCNVector3(1/level.scale,1/level.scale,1/level.scale)
        return node
     }
    
    private func getModelAnimation(for level: ConnectDotsGameLevel, onComplete: (()->Void)?) -> SCNNode {
        let modelNode = levelData.loadAnimation(level)
        let material = levelData.getAnimationMaterial(level)
        guard let node = modelNode as? SCNNode else {
            log.error("Model Animation node not conforming to SCNNode")
            return SCNNode()
        }
        log.verbose("Model Animation loaded")
        if let animationNode = node.childNodes.first {
            for childNode in animationNode.childNodes {
               childNode.geometry?.firstMaterial = material
               if let animationKey = childNode.animationKeys.first,
                    let animationPlayer = childNode.animationPlayer(forKey: animationKey) {
                    let animation = animationPlayer.animation
                    animation.usesSceneTimeBase = false
                    animation.repeatCount = 0
                  //  animation.duration = 0.833
                }
            }
            if let onCompleteNode = animationNode.childNodes.first {
                if let animationKey = onCompleteNode.animationKeys.first,
                    let animationPlayer = onCompleteNode.animationPlayer(forKey: animationKey) {
                    let animation = animationPlayer.animation
                    animation.animationDidStop = { _, _, _ in
                            onComplete?()
                    }
                }
            }
        }
        return node
    }
    
    private func addSphere( position: Vector, color: UIColor) {
        let scene = SCNScene(named: "sphere.scn")
        guard let sphere = scene?.rootNode.childNode(withName: "sphere", recursively: false) else {
            log.error("Balloon Node not found")
            return
        }
        currentGameNode?.addChildNode(sphere)
        sphere.geometry?.firstMaterial?.diffuse.contents = color
        sphere.geometry?.firstMaterial?.lightingModel = .physicallyBased
        sphere.worldPosition = position
    }
    
    private func addModel(for level: ConnectDotsGameLevel, onComplete: (() -> Void)?) {
        self.clearGameNode()
        let node = self.getModel(for: level)
        cameraNode?.addNode(node)
        self.currentGameNode = node
        onComplete?()
    }
    
    private func addModelAnimation(for level: ConnectDotsGameLevel) {
       self.clearGameNode()
        var node = currentGameModelAnimation
        if let position = anchorPosition, let angle = anchorAngle  {
            // In case there is already an anchor to place the objects at
            node.worldPosition = position
            node.eulerAngles = angle
        } else {
            // Will change this to only changing the position of the object
            node = self.orientNode(node: node)
        }
        node.scale = SCNVector3(Float(1/(level.scale-1)))
        cameraNode?.addNode(node)
        self.currentGameNode = node
    }
}
