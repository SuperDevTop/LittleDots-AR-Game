import SceneKit

class AnimationQueue: NSObject, CAAnimationDelegate {
    
    private var animationQueue = [() -> Void]()
    var isAnimating = false

    func isEmpty() -> Bool {
        return animationQueue.isEmpty
    }
    
    func append(_ function: @escaping (() -> Void)) {
        animationQueue.append(function)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if !animationQueue.isEmpty {
                animationQueue.removeFirst()()
            } else {
                isAnimating = false
            }
        }
    }
}
