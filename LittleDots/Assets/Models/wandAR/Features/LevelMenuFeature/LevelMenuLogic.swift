import Foundation

protocol LevelMenuLogicProtocol: FeatureLogicProtocol {
    func showMenu(onShowing: (()-> Void)?)
    func startLevel(_ tag: Int)
    func getCurrentLevel() -> ConnectDotsGameLevel?
    func getCurrentLevelStatus() -> LevelState?
    func getCurrentLives() -> Int
    func proceedToNextDot()
    func proceedToNextLevel() -> Bool
    func setCurrentLevelNil()
    func restartlevel()
    func reduceLife() -> Bool
    func levelComplete(_ level: ConnectDotsGameLevel)
    func getLevelState(_ levelNumber: Int) -> LevelState?
}

protocol LevelMenuViewProtocol: FeatureViewProtocol {
    func refreshImages()
}

struct LevelState{
    var number: Int
    var progress: levelProgress
    var dot: Int
    var livesLeft: Int
}

class LevelMenuLogic: LevelMenuLogicProtocol {
    private weak var view: LevelMenuViewProtocol?
    private weak var connectGameLogic: ConnectDotsGameLogicProtocol?
    private weak var cameraLogic: CameraLogicProtocol?
    
    private var currentLevel : ConnectDotsGameLevel?
    private var gameLevelState = [LevelState]()
    func initialize(root: RootProtocol, view: FeatureViewProtocol?, dependencies: [FeatureName : FeatureLogicProtocol]?) {
        guard let uiView = view as? LevelMenuViewProtocol else {
            log.error("Unknown view type")
            return
        }
        guard let deps = dependencies,
            let cameraLogic = deps[.CameraFeature] as? CameraLogicProtocol,
            let connectGameLogic = deps[.ConnectDotsGameFeature] as? ConnectDotsGameLogicProtocol else {
            log.error("Dependency unfulfilled")
            return
        }
        self.view = uiView
        self.connectGameLogic = connectGameLogic
        self.cameraLogic = cameraLogic
        self.initializeLevels()
    }
    
    func initializeLevels() {
        for i in 1...levelData.levels.count {
            let levelStatus = LevelState(number: i, progress: .locked, dot: 1, livesLeft: config.connectGameSceneParameters.maxLives)
            gameLevelState.append(levelStatus)
        }
        // Setting the first level to incomplete
        gameLevelState[0].progress = .done
        gameLevelState[1].progress = .incomplete
        gameLevelState[2].progress = .locked
        gameLevelState[3].progress = .locked
        self.view?.refreshImages()
     }
    
    func showMenu(onShowing: (()-> Void)?) {
        self.view?.show {
            self.setCurrentLevelNil()
            onShowing?()
        }
    }
    
    func getCurrentLevel() -> ConnectDotsGameLevel? {
        return currentLevel
    }
    
    func getLevelState(_ levelnumber: Int) -> LevelState? {
        guard let status = gameLevelState.first(where: { $0.number == levelnumber}) else {
            log.error("Level status not found")
            return nil
        }
        return status
    }
    
    func getCurrentLevelStatus() -> LevelState? {
        guard let level = self.currentLevel else {
            log.error("Current level not found")
            return nil
        }
        guard let status = gameLevelState.first(where: { $0.number == level.number}) else {
            log.error("Level status not found")
            return nil
        }
        return status
    }
    
    func setCurrentLevelNil() {
        currentLevel = nil
    }
    
    func proceedToNextDot()  {
        guard let level =  self.currentLevel else {
            log.error("Level not found")
            return
        }
        guard let status = self.getCurrentLevelStatus() else {
            log.error("Status not found")
            return
        }
        guard status.dot <= level.dots.count else {
            log.error("All dots done")
            return
        }
        self.gameLevelState[level.number-1].dot += 1
    }
    
    func resetLevel(_ level: ConnectDotsGameLevel) {
        guard level.number > 0 && level.number <= levelData.levels.count else {
            log.error("Level out of bounds")
            return
        }
        self.gameLevelState[level.number-1].dot = 1
        self.gameLevelState[level.number-1].progress = .incomplete
        self.gameLevelState[level.number-1].livesLeft = config.connectGameSceneParameters.maxLives
    }
    
    func restartlevel() {
        guard let level = currentLevel else {
            log.error("No current level to restart")
            return
        }
        self.resetLevel(level)
        self.loadLevel(level)
    }
    
    func reduceLife() -> Bool{
        guard let level =  self.currentLevel else {
            log.error("Level not found")
            return false
        }
        if self.gameLevelState[level.number-1].livesLeft > 1 {
            self.gameLevelState[level.number-1].livesLeft -= 1
            return true
        }
        self.resetLevel(level)
        return false
    }
    
    func getCurrentLives() -> Int {
        guard let level =  self.currentLevel else {
            log.error("Level not found")
            return -1
        }
        return self.gameLevelState[level.number-1].livesLeft
    }
    
    func levelComplete(_ level: ConnectDotsGameLevel) {
        guard gameLevelState.first(where: { $0.number == level.number}) != nil else {
            log.error("Level not found")
            return
        }
        self.gameLevelState[level.number-1].progress = .done
        guard gameLevelState.first(where: { $0.number == level.number + 1}) != nil else {
            log.error("Next level not found")
            return
        }
        self.unlockLevels(level.number)
    }
    
    func proceedToNextLevel() -> Bool{
        guard let level =  self.currentLevel else {
            log.error("Current level not found")
            return false
        }
        guard let levelToLoad = levelData.levels.first(where: { $0.number == level.number + 1}) else {
            log.error("Next level not found")
            return false
        }
        guard let status = gameLevelState.first(where: { $0.number == levelToLoad.number}) else {
            log.error("Next level status not found")
            return false
        }
        guard status.progress != .locked else {
            log.error("Level access not allowed")
            return false
        }
        self.loadLevel(levelToLoad)
        return true
    }
    
    func startLevel(_ tag: Int) {
        guard let level =  levelData.levels.first(where: { $0.number == tag }) else {
            log.error("Level Not Found")
            return
        }
        loadLevel(level)
    }
    
    func loadLevel(_ level: ConnectDotsGameLevel) {
        guard let status = gameLevelState.first(where: { $0.number == level.number}) else {
            log.error("Level Status Not found")
            return
        }
        log.verbose("Loading Level")
        switch status.progress {
        case .locked:
            self.lockedLevelNotify()
        default:
            self.view?.hide {}
            self.currentLevel = level
            self.connectGameLogic?.loadLevel(number: level, state: status) {}
        }
    }
    
    func lockedLevelNotify() {
        // Add the response, if any for tapping on the locked level
        log.warning("Locked Level")
    }
    
    func unlockLevels(_ levelNumber: Int) {
        guard gameLevelState.first(where: { $0.number == levelNumber + 1}) != nil else {
            log.error("Next Level Not found")
            return
        }
        if ( self.gameLevelState[levelNumber].progress == .locked ){
            self.gameLevelState[levelNumber].progress = .incomplete
        }
    }
    
    func applicationDidEnterForeground() {
        if let level = currentLevel {
            loadLevel(level)
        }
    }
    
    @objc
    func goBack() {
        self.view?.hide {}
    }
}


