import SceneKit

typealias Vector = SCNVector3
typealias Transform = SCNMatrix4

// swiftlint:disable identifier_name
extension Vector {
    init(_ value: Float) {
        self = SCNVector3(value, value, value)
    }
    func magnitude() -> Float {
        return sqrt(self.magnitudeSquared())
    }
    func magnitudeSquared() -> Float {
        return self.x * self.x +
            self.y * self.y +
            self.z * self.z
    }
    static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    static func == (lhs: Vector, rhs: Vector) -> Bool {
        return ((lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z))
    }
    
    static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    static func / (lhs: Vector, rhs: Float) -> Vector {
        return Vector(lhs.x / rhs, lhs.y/rhs, lhs.z/rhs )
    }
}

extension Transform {
    init() {
        self = SCNMatrix4Identity
    }
    func translate(_ x: Float, _ y: Float, _ z: Float) -> Transform {
        return SCNMatrix4Mult(SCNMatrix4MakeTranslation(x, y, z), self)
    }
    func scale(_ x: Float, _ y: Float, _ z: Float) -> Transform {
        return SCNMatrix4Mult(SCNMatrix4MakeScale(x, y, z), self)
    }
    func rotate(_ w: Float, _ x: Float, _ y: Float, _ z: Float) -> Transform {
        return SCNMatrix4Mult(SCNMatrix4MakeRotation(w, x, y, z), self)
    }
    func multiply(_ transform: Transform) -> Transform {
        return SCNMatrix4Mult(transform, self)
    }
    func distanceSquared(from transform: Transform) -> Float {
        return (self.positionVector() - transform.positionVector()).magnitudeSquared()
    }
    func distance(from transform: Transform) -> Float {
        return (self.positionVector() - transform.positionVector()).magnitude()
    }
    func positionVector() -> Vector {
        return Vector(self.m41, self.m42, self.m43)
    }
}
// swiftlint:enable identifier_name
