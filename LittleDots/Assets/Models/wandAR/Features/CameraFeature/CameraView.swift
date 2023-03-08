import ARKit
import SceneKit

// just makes SCNNode satisfy CameraViewNodeProtocol, so that
// feature views can create SCNNodes and pass them around to
// camera feature as CameraViewNodeProtocol
extension SCNNode: CameraViewNodeProtocol {
    func addChildNode(_ node: CameraViewNodeProtocol) {
        guard let scnNode = node as? SCNNode else {
            log.error("Node needs to be SCNNode")
            return
        }
        self.addChildNode(scnNode)
    }
}

extension CGPoint: PointProtocol {}

class CameraView: ARSCNView, ARSCNViewDelegate, CameraViewProtocol {

    weak var featureLogic: CameraLogicProtocol!
    var blurEffectView = UIVisualEffectView()
    private var trackingLabel = UILabel()
    private var currentTrackingStateString = "" {
        didSet {
            DispatchQueue.main.async {
                self.trackingLabel.text = self.currentTrackingStateString
            }
        }
    }
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? CameraLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.isUserInteractionEnabled = false
        self.delegate = self as ARSCNViewDelegate
        initUI()
        initConstraints()
    }

    func initUI() {
        self.autoenablesDefaultLighting = true
        self.debugOptions = [
//            .showWorldOrigin,
//            .showFeaturePoints,
//            .showBoundingBoxes,
        ]
        self.scene = SCNScene()
        self.addSubview(trackingLabel)
        trackingLabel.textColor = .white
        trackingLabel.font = UIFont(name: "FredokaOne-Regular", size: config.connectGameUIParameters.labelFont)
        
    }

    func initConstraints() {
        trackingLabel.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
    }

    // MARK: - Property getters and setters
    var cameraPosition: Vector {
        get {
            if let cameraNode = self.pointOfView {
                return cameraNode.position
            }
            return Vector()
        }
        set(newCameraPosition) {
            self.pointOfView?.position = newCameraPosition
        }
    }

    var cameraTransform: Transform {
        get {
            if let cameraNode = self.pointOfView {
                return cameraNode.transform
            }
            return Transform()
        }
        set(newCameraTransform) {
            self.pointOfView?.transform = newCameraTransform
        }
    }

    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.featureLogic.onRendererUpdate()
    }

    // MARK: - CameraViewProtocol

    func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        self.session.run(configuration)
        self.scene.physicsWorld.gravity = SCNVector3(0,self.scene.physicsWorld.gravity.y/6,0)
    }

    func stopARSession() {
        self.session.pause()
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            switch camera.trackingState {
            case .normal:
                self.currentTrackingStateString = ""
            case .notAvailable:
                self.currentTrackingStateString = "Get closer to the balloons, pop them!"
            case .limited(let reason):
                switch reason {
                case .excessiveMotion:
                    self.currentTrackingStateString = "Get closer to the balloons, pop them!"
                case .initializing:
                    self.currentTrackingStateString = "Get closer to the balloons, pop them!"
                case .insufficientFeatures:
                    self.currentTrackingStateString = "Get closer to the balloons, pop them!"
                case .relocalizing:
                    self.currentTrackingStateString = "Get closer to the balloons, pop them!"
            }
        }
    }

    func drawSphere(_ transform: Transform, radius: Float) {
        let geometry = SCNSphere(radius: CGFloat(radius))
        geometry.firstMaterial?.lightingModel = .blinn
        let node = SCNNode(geometry: geometry)
        node.transform = transform
        scene.rootNode.addChildNode(node)
    }

    func drawConfetti(_ transform: Transform) {
        let confettiNode = SCNNode()
        let confettiParticleSystem = SCNParticleSystem()
        let newTransform = transform.rotate(30, 1, 0, 0)

        confettiParticleSystem.loops = true
        confettiParticleSystem.birthRate = 5000
        confettiParticleSystem.emissionDuration = 1
        confettiParticleSystem.particleIntensity = 1
        confettiParticleSystem.spreadingAngle = 30
        confettiParticleSystem.particleDiesOnCollision = false
        confettiParticleSystem.particleLifeSpan = 5
        confettiParticleSystem.particleLifeSpanVariation = 0.3
        confettiParticleSystem.particleVelocity = 4
        confettiParticleSystem.particleVelocityVariation = 2
        confettiParticleSystem.particleSize = 0.003
        confettiParticleSystem.particleSizeVariation = 0.001
        confettiParticleSystem.particleColor = UIColor.red
        confettiParticleSystem.particleColorVariation = SCNVector4( 1, 0, 0, 0)
        confettiParticleSystem.particleMass = 0.1
        confettiParticleSystem.particleAngle = 20
        confettiParticleSystem.particleAngleVariation = 5
//        confettiParticleSystem.acceleration = SCNVector3(0.005,0.0001,0.005)
        confettiParticleSystem.isAffectedByGravity = true
        confettiNode.addParticleSystem(confettiParticleSystem)
        confettiNode.transform = newTransform
        scene.rootNode.addChildNode(confettiNode)
    }

    func addNode(_ node: CameraViewNodeProtocol) {
        guard let sceneNode = node as? SCNNode else {
            log.error("Invalid scene node provided to camera view")
            return
        }
        scene.rootNode.addChildNode(sceneNode)
    }

    func addShape(_ node: CameraViewNodeProtocol) {
        guard let sceneNode = node as? SCNNode else {
            log.error("Invalid scene node provided to camera view")
            return
        }
        let transform = self.scene.rootNode.convertTransform(SCNMatrix4MakeTranslation(0, 0, -0.25), from: self.pointOfView)
        sceneNode.transform = transform
        scene.rootNode.addChildNode(sceneNode)
    }

    func shareImageSubview(_ image: UIImage) -> UIImageView{
        let imageView = UIImageView(image: image)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(UIScreen.main.bounds.height)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        return imageView
    }

    func shareImageMenu(_ callback: @escaping () -> Void) {
        let image = self.snapshot()
        let viewController = topViewController()
        let imageView = shareImageSubview(image)
        self.addSubview(imageView)
        let imageToShare = [ image ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = viewController.view // so that iPads won't crash

        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.airDrop, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print, UIActivity.ActivityType.markupAsPDF]

        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                log.warning("User canceled the share")
            }
            imageView.removeFromSuperview()
            callback()
       }

        viewController.present(activityViewController, animated: true, completion: nil)
    }

    func topViewController()-> UIViewController{
        var topViewController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while ((topViewController.presentedViewController) != nil) {
            topViewController = topViewController.presentedViewController!;
        }
        return topViewController
    }

    func hitTestForNode( _ pos: PointProtocol) -> CameraViewNodeProtocol? {
        if let position = pos as? CGPoint {
            let hitTest = self.hitTest(position)
            for hit in hitTest {
                if hit.node.name == "Balloon" {
        //          log.verbose("Found Node: \(String(describing: hit.node))")
                    return hit.node.parent
                }
            }
        }
        return nil
    }

    func addBlur() {
        if !UIAccessibility.isReduceTransparencyEnabled
        {
            let blurEffect = UIBlurEffect(style: .regular)
            blurEffectView = CustomIntensityVisualEffectView(effect: blurEffect, intensity: 0.3)
//            blurEffectView = UIVisualEffectView(effect: blurEffect)
             //always fill the view
            blurEffectView.frame = UIScreen.main.bounds
            blurEffectView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            log.error("Couldn't Blur")
        }
    }

    func removeBlur() {
        blurEffectView.removeFromSuperview()
    }
}

class CustomIntensityVisualEffectView: UIVisualEffectView {

    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: Private
    private var animator: UIViewPropertyAnimator!

}


