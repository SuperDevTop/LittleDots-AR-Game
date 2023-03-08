import UIKit

struct Config {
    // Initialise the structures
    var fiddleMenuUIParameters = FiddleMenuUIParameters()
    var connectGameSceneParameters = ConnectGameSceneParameters()
    var connectGameUIParameters = ConnectGameUIParameters()
    var levelMenuUIParameters = LevelMenuUIParameters()
    
    // Fiddle View property
    struct FiddleMenuUIParameters {
        var screenPercentageCovered: CGFloat = 0.5
        var tableRowSize: CGFloat = 80
        var startX: CGFloat {
            return (1 - screenPercentageCovered) * UIScreen.main.bounds.maxX
        }
    }
    
    // Connect Game Logic
    struct ConnectGameSceneParameters {
        var gameCameraOffset:Float = 0.5
        var dotProximityDistance: CGFloat = 0.8
        var touchingDotOpacity: CGFloat = 1
        var nonTouchingDotOpacity: CGFloat = 0.5
        var fadeInDotDuration: CGFloat = 0.2
        var connectingLineRadius: CGFloat = 0.00175
        var maxLives: Int = 3
    }
   
    // Connect Game View
    struct ConnectGameUIParameters {
        var topBarMargin: CGFloat = 10
        var topBarMarginHide: CGFloat {
            return topBarMargin * -6
        }
        var labelFont: CGFloat = 20
        var labelBoldFont: CGFloat = 25
        var backButtonSize = 50
    }
    
    // Level Menu View
    struct LevelMenuUIParameters{
        var buttonAspectRatio: CGFloat = 7/5
        var titleHeightRatio: CGFloat = 0.1
    }
}

var config = Config()
