import UIKit
import SnapKit
import SceneKit

class ConnectDotsGameView: UIView, ConnectDotsGameViewProtocol {
    weak var featureLogic: ConnectDotsGameLogicProtocol!
    private let sceneView =  ConnectDotsGameSceneView()
    private let uiView = ConnectDotsGameUIView()
  
    // Fiddle View
    private let cancelView = UIView()
    
    // MARK: - Init Functions
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? ConnectDotsGameLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.addSubview(self.uiView)
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        self.isMultipleTouchEnabled = true
        self.alpha = 0
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.sceneView.show()
        self.uiView.show{}
        self.isUserInteractionEnabled = true
        self.alpha = 1
        onShowing?()
    }
    
    func hide(_ onHidden: (() -> Void)?) {
        self.sceneView.hide()
        self.uiView.hide{}
        self.isUserInteractionEnabled = false
        self.alpha = 0
        onHidden?()
    }

    func onTapRestartButton(_ target: Any?, _ handler: Selector) {
        self.uiView.onTapRestartButton(target, handler)
    }
    
    func onTapShareButton(_ target: Any?, _ handler: Selector) {
        self.uiView.onTapShareButton(target, handler)
    }
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.uiView.onTapBackButton(target, handler)
    }
    
    func onTapGame() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        self.featureLogic.handleDotTouch(point: location)
    }
    
    func onRightSwipe() {
//        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(addFiddleMenu(_:)))
//        swipeGesture.edges = .right
//        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func disableFiddleMenu() {
        self.cancelView.removeFromSuperview()
        self.featureLogic.hideFiddleMenu()
    }
    
    @objc func addFiddleMenu(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            self.cancelView.frame = self.frame
            let touchToCancel = UITapGestureRecognizer(target: self, action: #selector(disableFiddleMenu))
            self.addSubview(self.cancelView)
            cancelView.addGestureRecognizer(touchToCancel)
            self.featureLogic.showFiddleMenu()
        }
    }
    
    func startLevel(level: ConnectDotsGameLevel, state: LevelState) {
        guard let camera = self.featureLogic.cameraLogic else {
            log.error("Camera not initialized")
            return
        }
        switch state.progress {
        case .done:
            log.verbose("Loading a completed level")
          //  self.uiView.showTrackingAnimation {
                self.uiView.loadLevelCompleteView()
                self.sceneView.loadCompleteLevel(number: level, camera: camera)
          //  }
        case .incomplete:
            log.verbose("Loading an incomplete level")
            self.sceneView.prepareLevelNode(for: level)
            self.uiView.loadGamePlayView(livesLeft: state.livesLeft, onTrackingAnimationComplete: {
                DispatchQueue.global(qos: .background).async {
                     self.sceneView.loadInCompleteLevel(number: level, camera: camera, progress: state.dot)
                }
        })
       case .locked:
            log.error("Access Level Locked")
        }
    }
    
    func activateHighlightingDot(_ dot: ConnectDotsGameDot) {
        self.sceneView.activateHighlightingDot(dot)
    }

    func deactivateHighlightingDot(_ dot: ConnectDotsGameDot) {
        self.sceneView.deactivateHighlightingDot(dot)
    }
    
    func showSuccessfulDot(for dot: ConnectDotsGameDot) {
        self.sceneView.completeDot(dot)
    }
    
    func failAt(node: CameraViewNodeProtocol, livesLeft: Int, onComplete: (() -> Void)?) {
        self.sceneView.failAt(node: node, isLevelOver: livesLeft == 0, onComplete: onComplete)
        self.uiView.setLives(to: livesLeft)
    }
    
    func levelComplete(_ level: ConnectDotsGameLevel) {
        self.sceneView.levelComplete(level, onComplete: {
            DispatchQueue.main.async {
                self.uiView.loadLevelCompleteView()
            }
        })
     }
    
    func startShareAnimation(onComplete: (() -> Void)?) {
        self.uiView.animationShareMenu(onComplete: {
            self.uiView.flashAnimation(onComplete: {
                onComplete?()
            })
        })
    }
    
    func shareEnded() {
        self.uiView.loadLevelCompleteView()
    }
    
    func levelFailed() {
        self.sceneView.cleanSceneView()
        DispatchQueue.main.async {
            self.uiView.showlevelFailUI()
        }
    }
    
    func resetTracking() {
        self.uiView.resetTracking()
    }
    
    func isDotInProximity(_ cameraWorldTransform: Transform,_ dot: ConnectDotsGameDot) -> Bool? {
       return self.sceneView.isDotInProximity(cameraWorldTransform, dot)
    }
    
    func isNodeInProximity(_ cameraWorldTransform: Transform,_ nodeWorldTransform: Transform) -> Bool{
        return self.sceneView.isNodeInProximity(cameraWorldTransform, nodeWorldTransform)
    }
}
