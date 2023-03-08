import UIKit
import SnapKit

class LevelMenuView: UIView, LevelMenuViewProtocol {
    // MARK: - UI
    weak var featureLogic: LevelMenuLogicProtocol!

    // Loading assests
    let settings = UIButton()
    // UIImageView for images that will be directly rendered on the UIView
    let titleImage = UIImageView(image: UIImage(named: "titleImage.png"))
    // UIImage for assests for button images
    let unlockedLevelImage = UIImage(named: "unlockedLevel.png")
    let lockedLevelImage = UIImage(named: "lockedLevel.png")
    let unlockedLevelCard = UIImage(named: "cardNew.png")
    let lockedLevelCard = UIImage(named: "cardLocked.png")
    let doneLevelCard = UIImage(named: "cardDone.png")
   
    var levelButtons = [UIButton]()
    // This UI only works for 4 levels now.
    let buttonView = UIView()
    let numberOfLevels = 4
    
    // Button dimension variables to be accesed later
    var buttonWidth: CGFloat?
    var buttonHeight: CGFloat?
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? LevelMenuLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.layer.zPosition = 8
        self.isUserInteractionEnabled = true
        initUI()
        initConstraints()
        initBehavior()
        self.alpha = 1
    }
    
    func initUI() {
        for i in 1...4 {
            let button = UIButton()
            button.tag = i
            button.layer.cornerRadius = 15
            button.layer.borderWidth = 3
            button.addTarget(self, action: #selector(onLevelSelect(_:)), for: UIControl.Event.touchUpInside)
            levelButtons.append(button)
            buttonView.addSubview(button)
        }
        settings.setImage(UIImage(named: "setting.png"), for: UIControl.State.normal)
       // Add all the sub-views
        self.titleImage.contentMode = .center
        self.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundLevelMenu.png")!)
//        self.addSubview(settings)
        self.addSubview(buttonView)
        self.addSubview(titleImage)
     }
    
    func initConstraints() {
        let screenHeight = UIScreen.main.bounds.height
        let buttonHeight = screenHeight * 0.38
        let buttonWidth = buttonHeight * config.levelMenuUIParameters.buttonAspectRatio
        let spacing = buttonHeight * 0.07
        let buttonViewWidth = 2 * buttonWidth + spacing
        let buttonViewHeight = 2 * buttonHeight + spacing
        let topSpacing = spacing * 2.3
        self.buttonHeight = buttonHeight
        self.buttonWidth = buttonWidth
        titleImage.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(config.levelMenuUIParameters.titleHeightRatio)
            make.top.equalToSuperview().inset(topSpacing)
        }
//        settings.snp.makeConstraints{ make in
//            make.top.equalToSuperview().inset(topSpacing)
//            make.leading.equalToSuperview().inset(topSpacing)
//        }
        buttonView.snp.makeConstraints{ make in
            make.height.equalTo(buttonViewHeight)
            make.width.equalTo(buttonViewWidth)
            make.bottom.equalToSuperview().inset(spacing)
            make.centerX.equalToSuperview()
        }
        for button in levelButtons{
            button.snp.makeConstraints{ make in
                make.height.equalTo(buttonHeight)
                make.width.equalTo(buttonWidth)
            }
        }
        levelButtons[0].snp.makeConstraints{ make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        levelButtons[1].snp.makeConstraints{ make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        levelButtons[2].snp.makeConstraints{ make in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        levelButtons[3].snp.makeConstraints{ make in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    func onLevelSelect(_ sender: UIButton) {
        self.featureLogic.startLevel(sender.tag)
    }
   
    func initBehavior() {
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.refreshImages()
        self.alpha = 1
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { _ in
            self.isUserInteractionEnabled = true
            onShowing?()
        })
    }
   
    func hide(_ onHidden: (() -> Void)?) {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        }, completion: { _ in
            onHidden?()
            self.alpha  = 0
        })
    }
    
    func refreshImages() {
        for button in levelButtons {
            if let state = self.featureLogic.getLevelState(button.tag) {
                setImage(button, state)
            }
        }
    }
    
    func setImage(_ button: UIButton, _ state: LevelState) {
        guard let level = levelData.levels.first(where: {$0.number == button.tag}) else {
            log.error("No Level Found")
            return
        }
        guard let width = buttonWidth else {
            log.error("Button Dimenstions not found")
            return
        }
        switch state.progress {
        case .done:
            button.isEnabled = true
            button.setImage(level.image, for: UIControl.State.normal)
            button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0.15 * width, bottom: 0, right: 0.15 * width)
     //       button.backgroundColor = UIColor(red: 246/255, green: 250/255, blue: 192/255, alpha: 0.75)
            button.backgroundColor = UIColor(red: 1, green: 1, blue: 10.0, alpha: 0.50)
            button.layer.borderColor = UIColor(red: 246/255, green: 216/255, blue: 121/255, alpha: 1).cgColor
            break
        case .incomplete:
            button.isEnabled = true
            button.setImage(unlockedLevelImage, for: UIControl.State.normal)
            button.imageView?.contentMode = .bottom
            button.backgroundColor = UIColor(red: 255/255, green: 144/255, blue: 122/255, alpha: 1)
            button.layer.borderColor = UIColor(red: 255/255, green: 120/255, blue: 124/255, alpha: 1).cgColor
            break
        case .locked:
            button.isEnabled = false
            button.setImage(lockedLevelImage, for: UIControl.State.disabled)
            button.backgroundColor = UIColor(red: 92/255, green: 207/255, blue: 211/255 , alpha: 1)
            button.layer.borderColor = UIColor(red: 0/255, green: 151/255, blue: 207/255 , alpha: 1).cgColor
            break
        }
    }
}



