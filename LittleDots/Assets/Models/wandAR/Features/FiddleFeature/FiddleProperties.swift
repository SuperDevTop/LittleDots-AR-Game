import Foundation
import UIKit

struct ConfigProperty {
    let propertyName: String
    var value: Float
    let minBound: Float
    let maxBound: Float
}

struct Section {
    let name: String
    var properties: [ConfigProperty]
}

class FiddleProperties {
    //Remember to add the attribute to display the feature in both the array and the didSet function
    //IMPORTANT! - Keep the property order same in the didSet function toos
    var tableData = [
        Section(name: "Level Menu Screen",
                properties:[
                    ConfigProperty(
                        propertyName: "Button Aspect Ratio",
                        value: Float(config.levelMenuUIParameters.buttonAspectRatio),
                        minBound: 0,
                        maxBound: 10
                    ),
                    ConfigProperty(
                        propertyName: "Row Size",
                        value: Float(config.levelMenuUIParameters.titleHeightRatio),
                        minBound: 0,
                        maxBound: 1
                     ),
                    ]),
        Section(name: "Connect Game UI Screen",
                properties:[
                    ConfigProperty(
                        propertyName: "Top Menu Margin",
                        value: Float(config.connectGameUIParameters.topBarMargin),
                        minBound: 0,
                        maxBound: 50
                    ),
                    ConfigProperty(
                        propertyName: "Label Font",
                        value: Float(config.connectGameUIParameters.labelFont),
                        minBound: 5,
                        maxBound: 50
                    ),
                    ConfigProperty(
                        propertyName: "Label Bold Font",
                        value: Float(config.connectGameUIParameters.labelBoldFont),
                        minBound: 5,
                        maxBound: 50
                    ),
                    ]),
        Section(name: "Connect Game 3D Screen",
                properties:[
                    ConfigProperty(
                        propertyName: "Object Distance",
                        value: config.connectGameSceneParameters.gameCameraOffset,
                        minBound: 0,
                        maxBound: 5
                    ),
                    ConfigProperty(
                        propertyName: "Highlight Distance",
                        value: Float(config.connectGameSceneParameters.dotProximityDistance),
                        minBound: 0,
                        maxBound: 5
                    ),
                    ConfigProperty(
                        propertyName: "Non-Touching Opacity",
                        value: Float(config.connectGameSceneParameters.nonTouchingDotOpacity),
                        minBound: 0,
                        maxBound: 1
                     ),
                    ConfigProperty(
                        propertyName: "Fade Duration",
                        value: Float(config.connectGameSceneParameters.fadeInDotDuration),
                        minBound: 0,
                        maxBound: 5
                    ),
                    ConfigProperty(
                        propertyName: "Line Radius",
                        value: Float(config.connectGameSceneParameters.connectingLineRadius),
                        minBound: 0,
                        maxBound: 0.01
                    ),
                    ]),
        ] {
        didSet {
            config.levelMenuUIParameters.buttonAspectRatio = CGFloat(self.tableData[0].properties[0].value)
            config.levelMenuUIParameters.titleHeightRatio = CGFloat(self.tableData[0].properties[1].value)
            config.connectGameUIParameters.topBarMargin = CGFloat(self.tableData[1].properties[0].value)
            config.connectGameUIParameters.labelFont = CGFloat(self.tableData[1].properties[1].value)
            config.connectGameUIParameters.labelBoldFont = CGFloat(self.tableData[1].properties[2].value)
            config.connectGameSceneParameters.gameCameraOffset = self.tableData[2].properties[0].value
            config.connectGameSceneParameters.dotProximityDistance = CGFloat(self.tableData[2].properties[1].value)
            config.connectGameSceneParameters.nonTouchingDotOpacity = CGFloat(self.tableData[2].properties[2].value)
            config.connectGameSceneParameters.fadeInDotDuration = CGFloat(self.tableData[2].properties[3].value)
            config.connectGameSceneParameters.connectingLineRadius = CGFloat(self.tableData[2].properties[4].value)
        }
    }
}
var property = FiddleProperties()
