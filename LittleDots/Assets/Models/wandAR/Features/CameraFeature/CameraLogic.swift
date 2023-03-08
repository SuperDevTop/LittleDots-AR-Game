protocol CameraViewNodeProtocol {
    var name: String? { get set }
    var transform: Transform { get set }
    var worldTransform: Transform { get }
    var eulerAngles: Vector { get set}
    func addChildNode(_ node: CameraViewNodeProtocol)
    func removeFromParentNode()
}

protocol UIImageProtocol{
}

protocol CameraViewProtocol: FeatureViewProtocol {
    func startARSession()
    func stopARSession()
    var cameraPosition: Vector { get }
    var cameraTransform: Transform { get }
    func drawSphere(_ transform: Transform, radius: Float)
    func drawConfetti(_ transform: Transform)
    func hitTestForNode( _ pos: PointProtocol) -> CameraViewNodeProtocol?
    func addNode(_ node: CameraViewNodeProtocol)
    func addShape(_ node: CameraViewNodeProtocol)
    func shareImageMenu(_ callback: @escaping () -> Void)
    func addBlur()
    func removeBlur()
}

enum ShapeName {
    case sphere
}

protocol PointProtocol {}

protocol CameraLogicProtocol: FeatureLogicProtocol {
    var cameraTransform: Transform? { get }
    func addShape(_ shape: ShapeName)
    func addShapes(_ node: CameraViewNodeProtocol)
    func addConfetti(x: Float, y: Float, z: Float)
    func addNode(_ node: CameraViewNodeProtocol)
    func addRendererCallback(_ callback: @escaping () -> Void)
    func hitTest(_ pos : PointProtocol) -> CameraViewNodeProtocol?
    func onRendererUpdate()
    func shareImage(_ callback: @escaping () -> Void)
    func addBlur()
    func removeBlur()
}

class CameraLogic: CameraLogicProtocol {

    private weak var view: CameraViewProtocol?
    var rendererCallbacks: [() -> Void] = []

    // MARK: - FeatureProtocol conformance
    func initialize(root: RootProtocol,
                    view: FeatureViewProtocol?,
                    dependencies: [FeatureName: FeatureLogicProtocol]?) {
        guard let uiView = view as? CameraViewProtocol else {
            log.error("Unknown view type")
            return
        }
        self.view = uiView
    }

    func willAppear(_ animated: Bool) {
        log.verbose("Starting AR session")
        view?.startARSession()
    }

    func willDisappear(_ animated: Bool) {
        log.verbose("Stopping AR session")
        view?.stopARSession()
    }

    // MARK: - CameraLogicProtocol conformance
    func addConfetti(x: Float, y: Float, z: Float) {
        guard let cameraView = view else {
            log.error("Camera view not initialized!")
            return
        }
        cameraView.drawConfetti(cameraView.cameraTransform.translate(x, y, z))
    }

    var cameraTransform: Transform? {
        get {
            return self.view?.cameraTransform
        }
    }

    func addShape(_ shape: ShapeName) {
        log.verbose("Adding shape \(shape)")
        guard let cameraView = view else {
            log.error("Camera view not initialized!")
            return
        }
        switch shape {
        case .sphere:
            cameraView.drawSphere(cameraView.cameraTransform.translate(0, 0, -0.5), radius: 0.1)
        }
    }
    
    func addBlur() {
         self.view?.addBlur()
    }
    
    func removeBlur() {
        self.view?.removeBlur()
    }

    func addNode(_ node: CameraViewNodeProtocol) {
        guard let cameraView = self.view else {
            log.error("Camera view not initialized")
            return
        }
        log.verbose("Adding Node: \(String(describing: node))")
        cameraView.addNode(node)
    }

    func addShapes(_ node: CameraViewNodeProtocol) {
        guard let cameraView = view else {
            log.error("Camera view not initialized")
            return
        }
        log.verbose("Adding Node: \(String(describing: node))")
        cameraView.addShape(node)
    }

    func addRendererCallback(_ callback: @escaping () -> Void) {
        self.rendererCallbacks.append(callback)
    }

    func onRendererUpdate() {
        for callback in self.rendererCallbacks {
            callback()
        }
    }
    
    func shareImage(_ callback: @escaping () -> Void) {
        self.view?.shareImageMenu(callback)
    }
    
    func hitTest(_ pos : PointProtocol) -> CameraViewNodeProtocol? {
        return self.view?.hitTestForNode(pos)
    }
}
