import SceneKit

extension SCNNode {
    static func makeline(from startPoint: Vector,to endPoint: Vector, radius: CGFloat, color: UIColor) -> SCNNode {
        let node = SCNNode()
        let height = (startPoint - endPoint).magnitude()
        let radius = radius
        let color = color
        let cylinderEnd = SCNNode()
        cylinderEnd.position = startPoint
        cylinderEnd.position.y += height
        // Two vectors calculated, to find out the axis of rotation
        let vectorA = endPoint - startPoint
        let vectorB =  cylinderEnd.position - startPoint
        if vectorA.magnitude() == 0 || vectorB.magnitude() == 0 {
            // In case both points coincide
            return SCNNode(geometry: SCNSphere(radius: radius))
        }
        node.position = startPoint
        // Cross product to find
        let normalVector = SCNVector3(x: vectorA.y * vectorB.z - vectorA.z * vectorB.y,
                                      y: vectorA.z * vectorB.x - vectorA.x * vectorB.z,
                                      z: vectorA.x * vectorB.y - vectorA.y * vectorB.x)
        let dotProduct = SCNFloat((vectorA.x * vectorB.x + vectorA.y * vectorB.y + vectorA.z * vectorB.z))
        // Using the formula ||A X B|| = ||A|| * ||B|| * sin(theta)
        var sineAngle = normalVector.magnitude() / ( vectorA.magnitude() * vectorB.magnitude() )
        if sineAngle > 1 {
            sineAngle = 1
        }
        var angle = SCNFloat(asin(sineAngle))
        if dotProduct < 0 {
            angle = Float(Double.pi) - angle
        }
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = color
        node.geometry = cylinder
        if normalVector.magnitude() == 0 {
            // In case the vectors are along Y axis, that is become parallel
            if endPoint == cylinderEnd.position {
                node.pivot = SCNMatrix4MakeTranslation(0, -height/2, 0)
                return node
            } else {
                // TODO: Recheck what the error was
                // Line was forming in the other direction
                node.pivot = SCNMatrix4MakeTranslation(0, -height/2, 0)
                return node
            }
        }
        node.pivot = SCNMatrix4MakeTranslation(0, -height/2, 0)
        node.rotation = SCNVector4(normalVector.x, normalVector.y, normalVector.z, -angle)
        return node
    }
    
}
