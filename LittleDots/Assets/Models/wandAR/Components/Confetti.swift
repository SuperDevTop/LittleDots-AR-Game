import SceneKit

class ConfettiNode: SCNNode {
    
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
        confettiParticles.birthRate = 125
        confettiParticles.birthDirection = .surfaceNormal
        confettiParticles.emissionDuration = 0.1
        confettiParticles.particleIntensity = 1
        confettiParticles.spreadingAngle = 90
        confettiParticles.particleLifeSpan = 0.2
        confettiParticles.particleVelocity = 0.7
        confettiParticles.particleVelocityVariation = 0.3
        confettiParticles.particleSize = 0.005
        confettiParticles.particleSizeVariation = 0.005
        confettiParticles.particleColor = UIColor.red
        confettiParticles.particleMass = 0.0001
        confettiParticles.particleImage = UIImage(named: "confetti.png")
        confettiParticles.emitterShape = SCNSphere(radius: 0.05)
        confettiParticles.isAffectedByGravity = true
        return confettiParticles
    }
    
}
