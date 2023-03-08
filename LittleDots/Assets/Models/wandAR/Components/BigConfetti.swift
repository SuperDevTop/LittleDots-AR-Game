import SceneKit

class BigConfettiNode: SCNNode {
    
    override init() {
        super.init()
        self.constraints = [SCNBillboardConstraint()]
        self.pivot = Transform().translate(0, 0, 0.05)
        self.name = "confetti"
        self.addParticleSystem(getConfettiParticles())
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getConfettiParticles() -> SCNParticleSystem{
        let confettiParticles = SCNParticleSystem()
        confettiParticles.loops = false
        confettiParticles.birthRate = 300
        confettiParticles.birthDirection = .surfaceNormal
        confettiParticles.emissionDuration = 0.2
        confettiParticles.particleIntensity = 1
        confettiParticles.spreadingAngle = 90
        confettiParticles.particleLifeSpan = 0.4
        confettiParticles.particleVelocity = 1.0
        confettiParticles.particleVelocityVariation = 0.3
        confettiParticles.particleSize = 0.005
        confettiParticles.particleSizeVariation = 0.005
        confettiParticles.particleColor = UIColor.red
        confettiParticles.particleColorVariation = SCNVector4(0.2,0.5,0.5,0)
        confettiParticles.particleMass = 0.0001
        confettiParticles.particleImage = UIImage(named: "confetti.png")
        confettiParticles.emitterShape = SCNSphere(radius: 0.05)
        confettiParticles.isAffectedByGravity = true
        return confettiParticles
    }
    
}
