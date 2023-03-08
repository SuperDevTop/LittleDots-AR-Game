import Foundation

protocol FiddleLogicProtocol: FeatureLogicProtocol {
    func showMenu()
    func hideMenu()
}

protocol FiddleViewProtocol: FeatureViewProtocol {
}

class FiddleLogic: FiddleLogicProtocol {
    private weak var view: FiddleViewProtocol?

    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? FiddleViewProtocol else {
            log.error("Unknown view type")
            return
        }
       self.view = uiView
    }
    
    func showMenu() {
        self.view?.show {}
    }
    
    func hideMenu() {
        self.view?.hide{}
    }
}
