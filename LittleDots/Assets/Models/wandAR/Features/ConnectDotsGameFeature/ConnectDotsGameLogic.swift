import Foundation

protocol ConnectDotsGameLogicProtocol: FeatureLogicProtocol {
    var cameraLogic: CameraLogicProtocol? { get }
    func proceedToNextDot()
    func handleDotTouch(point: PointProtocol)
    func showFiddleMenu()
    func hideFiddleMenu()
    func loadLevel(number level: ConnectDotsGameLevel, state: LevelState, onStop: @escaping () -> Void)
}

protocol ConnectDotsGameViewProtocol: FeatureViewProtocol {
    // Level start
    func startLevel(level: ConnectDotsGameLevel, state: LevelState)
    func levelComplete(_ level: ConnectDotsGameLevel)
    func levelFailed()
    // Game actions
    func showSuccessfulDot(for dot: ConnectDotsGameDot)
    func failAt(node: CameraViewNodeProtocol, livesLeft: Int, onComplete: (() -> Void)?)
    // Helper functions
    func activateHighlightingDot(_ dot: ConnectDotsGameDot)
    func deactivateHighlightingDot(_ dot: ConnectDotsGameDot)
    func resetTracking()
    func isNodeInProximity(_ cameraWorldTransform: Transform,_ nodeWorldTransform: Transform) -> Bool
    func isDotInProximity(_ cameraWorldTransform: Transform,_ dot: ConnectDotsGameDot ) -> Bool?
    // Action handlers
    func onTapGame()
    func onRightSwipe()
    func onTapRestartButton(_ target: Any?, _ handler: Selector)
    func onTapBackButton(_ target: Any?, _ handler: Selector)
    func onTapShareButton(_ target: Any?, _ handler: Selector)
    func startShareAnimation(onComplete: (() -> Void)?)
    func shareEnded()
}

extension ConnectDotsGameDot: Comparable {
    static func < (lhs: ConnectDotsGameDot, rhs: ConnectDotsGameDot) -> Bool {
        return lhs.name < rhs.name
    }

    static func == (lhs: ConnectDotsGameDot, rhs: ConnectDotsGameDot) -> Bool {
        return lhs.name == rhs.name
    }
}

class ConnectDotsGameLogic: ConnectDotsGameLogicProtocol {
    private weak var view: ConnectDotsGameViewProtocol?
    private weak var levelMenuLogic: LevelMenuLogicProtocol?
    weak var cameraLogic: CameraLogicProtocol?
    private weak var fiddleLogic: FiddleLogicProtocol?
    
    var touchingDot: ConnectDotsGameDot?
    private var onStop: (() -> Void)?
    var isShowing: Bool {
        get {
            return self.onStop != nil
        }
    }
    var isLoading: Bool = false
    var canPlay: Bool = true
    
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? ConnectDotsGameViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let cameraLogic = deps[.CameraFeature] as? CameraLogicProtocol,
            let levelMenuLogic = deps[.LevelMenuFeature] as? LevelMenuLogicProtocol,
            let fiddleLogic = deps[.FiddleFeature] as? FiddleLogicProtocol else {
            log.error("Dependency unfulfilled")
            return
        }
        self.levelMenuLogic = levelMenuLogic
        self.fiddleLogic = fiddleLogic
        self.cameraLogic = cameraLogic
        self.cameraLogic?.addRendererCallback {
            self.onRendererUpdate()
        }
        self.view = uiView
        self.view?.onTapBackButton(self, #selector(goBack))
        self.view?.onTapShareButton(self, #selector(shareImage))
        self.view?.onTapRestartButton(self, #selector(onLevelRestart))
        self.view?.onTapGame()
        self.view?.onRightSwipe()
    }

    @objc
    func goBack() {
        self.levelMenuLogic?.showMenu {
            log.verbose("Stopping connect dots game")
            self.onStop?()
            self.onStop = nil
            self.view?.hide {}
        }
    }
    
    func showFiddleMenu() {
        fiddleLogic?.showMenu()
    }
    
    func hideFiddleMenu() {
        fiddleLogic?.hideMenu()
    }
    
    func onRendererUpdate() {
        if !self.isShowing || self.isLoading {
            return
        }
        guard let cameraTransform = self.cameraLogic?.cameraTransform else {
            log.error("Camera not available")
            return
        }
        guard let level = self.levelMenuLogic?.getCurrentLevel(), let state = self.levelMenuLogic?.getCurrentLevelStatus() else {
            log.error("Level dots not available")
            return
        }
        guard state.progress == .incomplete && state.dot <= level.dots.count else {
            return
        }
        for i in state.dot...level.dots.count{
            if let dot = level.dots.first(where: { $0.name == String(i)}){
                if let isNearBy = self.view?.isDotInProximity(cameraTransform, dot) {
                    if isNearBy {
                        self.view?.activateHighlightingDot(dot)
                    } else {
                        self.view?.deactivateHighlightingDot(dot)
                    }
                } else {
//                    log.error("Node not found for the dot")
                }
            }
        }
    }

    func handleDotTouch(point: PointProtocol) {
        if !self.canPlay {
            return
        }
        guard let cameraTransform = self.cameraLogic?.cameraTransform else {
            log.error("Camera not available")
            return
        }
        guard let node = self.cameraLogic?.hitTest(point) else {
            log.verbose("No node at the point")
            return
        }
        guard let currentDot = self.levelMenuLogic?.getCurrentLevelStatus()?.dot else {
            log.error("Current dot status not found")
            return
        }
        guard let proximity = self.view?.isNodeInProximity(cameraTransform, node.worldTransform) else {
            log.error("Distance not calculated")
            return
        }
        if proximity {
            if let name = node.name, let number = Int(name), number >= currentDot {
                if node.name == String(currentDot) {
                    self.proceedToNextDot()
                    log.verbose("Passed at current Point")
                } else {
                    self.failAtCurrentDot(node)
                    log.verbose("Failed at current Point")
                }
            }
        } else {
            log.verbose("Node not nearby")
        }
    }
    
    func loadLevel(number level: ConnectDotsGameLevel, state: LevelState, onStop: @escaping () -> Void) {
        self.onStop = onStop
        self.canPlay = true
        self.view?.show({
            self.view?.startLevel(level: level, state: state)
        })
    }
    
    func proceedToNextDot() {
        guard let level = self.levelMenuLogic?.getCurrentLevel() else {
            log.error("Level not found")
            return
        }
        guard let status = self.levelMenuLogic?.getCurrentLevelStatus() else {
            return
        }
        guard let dot = level.dots.first(where: { $0.name == String(status.dot)}) else {
            log.error("Dot Not found")
            return
        }
        self.levelMenuLogic?.proceedToNextDot()
        self.view?.showSuccessfulDot(for: dot)
        if isLevelComplete() {
            levelComplete()
        }
    }
    
    func isLevelComplete() -> Bool{
        guard let level = self.levelMenuLogic?.getCurrentLevel() else {
            log.error("Level not found")
            return false
        }
        guard let status = self.levelMenuLogic?.getCurrentLevelStatus() else {
            return false
        }
        if status.dot > level.dots.count {
            return true
        }
        return false
    }
    
    func levelComplete() {
        guard let level = self.levelMenuLogic?.getCurrentLevel() else {
            log.error("Level not found")
            return
        }
        self.view?.levelComplete(level)
        self.levelMenuLogic?.levelComplete(level)
    }

    @objc
    func shareImage() {
        log.verbose("Sharing the image")
        self.view?.startShareAnimation(onComplete: {
            self.showShareOptions(onComplete: {
                self.view?.shareEnded()
            })
        })
    }
    
    func showShareOptions(onComplete: (() -> Void)?) {
       cameraLogic?.shareImage{
            onComplete?()
       }
    }

    func failAtCurrentDot(_ node: CameraViewNodeProtocol) {
        guard let levelLogic = levelMenuLogic else {
            log.error("No level logic file found")
            return
        }
        if levelLogic.reduceLife() {
            // Life reduced
            self.canPlay = false
            self.view?.failAt(node: node, livesLeft: levelLogic.getCurrentLives(), onComplete: {
                self.canPlay = true
            })
         } else {
            // Level to be restarted
            self.canPlay = false
            self.view?.failAt(node: node, livesLeft: 0, onComplete: {
                self.view?.levelFailed()
            })
        }
    }
    
    func applicationDidEnterBackground() {
        self.view?.hide{
            self.view?.resetTracking()
        }
    }
    
    @objc func onLevelRestart() {
        self.onStop = nil
        self.view?.hide{}
        levelMenuLogic?.restartlevel()
        self.canPlay = true
    }
}
