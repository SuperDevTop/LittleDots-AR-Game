import UIKit

class ConnectDotsGameUIView: UIView {
    
    // UI Elements
    // 1. Top Bar
    let topBarStack = UIStackView()
    let backButton = UIButton()
    let livesStack = UIStackView()
    var livesImageViews = [UIImageView]()
    let lifeFilled = UIImage(named: "livesBalloonFilled.png")
    let lifeUnfilled = UIImage(named: "livesBalloonUnfilled.png")
    // 2. Share Menu
    let levelEndButtonStack = UIStackView()
    let shareButton = UIButton()
    let restartLevelSuccessButton = UIButton()
    let snapItTextLabel = UILabel()
    let restartLevelShareMenuButton = UIButton()
    let restartLevelShareMenuText = UILabel()
    let restartLevelShareMenuStack = UIStackView()
    // 3. Fail Menu
    let levelFailUI = UIView()
    let restartLevelFailButton = UIButton()
    let restartLevelFailText = UILabel()
    let restartLevelFailStack = UIStackView()
    let failLevelImageView = UIImageView(image: UIImage(named: "failImage.png"))
    let gameFont = UIFont(name: "FredokaOne-Regular", size: config.connectGameUIParameters.labelFont)
    // 4. Tracking View
    let trackingView = UIView()
    let trackingLabel = UILabel()
    let trackingImageView = UIImageView(image: UIImage(named: "trackingImage"))
    let trackingTextImageView = UIImageView(image: UIImage(named: "trackingText"))
    
    convenience init () {
        self.init(frame: UIScreen.main.bounds)
        initUI()
        initConstraints()
        
    }
    
    private func initUI() {
        initTrackingView()
        initLevelFailView()
        initGamePlayView()
        initLevelCompleteView()
    }
    
    private func initTrackingView() {
        initLivesUI()
        self.hidelevelFailUI()
        trackingView.frame = self.frame
        self.addSubview(trackingView)
        trackingView.addSubview(trackingImageView)
        trackingView.addSubview(trackingTextImageView)
        trackingView.addSubview(trackingLabel)
    }
    
    private func initGamePlayView() {
        //Back button
        backButton.setImage(UIImage(named: "back.png"), for: UIControl.State.normal)
        // Setting up top bar
        self.topBarStack.axis = .horizontal
        self.topBarStack.distribution = .equalSpacing
        // Top bar components
        self.topBarStack.addArrangedSubview(backButton)
        self.topBarStack.addArrangedSubview(livesStack)
        self.addSubview(topBarStack)
    }
    
    private func initLevelCompleteView() {
        // Setting up share menu
        self.levelEndButtonStack.axis = .vertical
        self.levelEndButtonStack.distribution = .equalSpacing
        // Share menu components
        self.levelEndButtonStack.addArrangedSubview(shareButton)
        self.levelEndButtonStack.addArrangedSubview(snapItTextLabel)
        // Setting up menu elements
        self.snapItTextLabel.text = "Snap It!"
        self.snapItTextLabel.textColor = .white
        self.snapItTextLabel.textAlignment = .center
        self.snapItTextLabel.font = gameFont
        shareButton.setImage(UIImage(named: "share.png"), for: UIControl.State.normal)
        self.addSubview(levelEndButtonStack)
        
        restartLevelShareMenuStack.addArrangedSubview(restartLevelShareMenuButton)
        restartLevelShareMenuStack.addArrangedSubview(restartLevelShareMenuText)
        self.restartLevelShareMenuStack.axis = .vertical
        self.restartLevelShareMenuStack.distribution = .equalSpacing
        self.restartLevelShareMenuText.text = "Re-try"
        self.restartLevelShareMenuText.textColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        self.restartLevelShareMenuText.font = gameFont
        self.restartLevelShareMenuText.textAlignment = .center
        self.restartLevelShareMenuButton.setImage(UIImage(named: "restartButton.png"), for: UIControl.State.normal)
        self.addSubview(restartLevelShareMenuStack)
    }
    
    private func initLevelFailView(){
        // Fail Level UI
        levelFailUI.frame = self.frame
        restartLevelFailStack.addArrangedSubview(restartLevelFailButton)
        restartLevelFailStack.addArrangedSubview(restartLevelFailText)
        self.restartLevelFailStack.axis = .vertical
        self.restartLevelFailStack.distribution = .equalSpacing
        self.restartLevelFailText.text = "Re-try"
        self.restartLevelFailText.textColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        self.restartLevelFailText.font = gameFont
        self.restartLevelFailText.textAlignment = .center
        self.restartLevelFailButton.setImage(UIImage(named: "restartButton.png"), for: UIControl.State.normal)
        self.addSubview(levelFailUI)
        levelFailUI.addSubview(restartLevelFailStack)
        levelFailUI.addSubview(failLevelImageView)
    }
    
    private func initConstraints() {
        topBarStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(config.connectGameUIParameters.topBarMargin)
            make.topMargin.equalToSuperview().offset(config.connectGameUIParameters.topBarMarginHide)
            make.width.equalToSuperview().inset(2*config.connectGameUIParameters.topBarMargin)
        }
        backButton.snp.makeConstraints{ make in
            make.width.height.equalTo(config.connectGameUIParameters.backButtonSize)
        }
        levelEndButtonStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(UIScreen.main.bounds.width * 0.05)
            make.bottom.equalToSuperview().inset(-180)
        }
        restartLevelShareMenuStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(UIScreen.main.bounds.width * 0.05)
            make.bottom.equalToSuperview().inset(-180)
        }
        restartLevelFailStack.snp.makeConstraints{ make in
            make.leading.equalToSuperview().inset(UIScreen.main.bounds.width * 0.05)
            make.bottom.equalToSuperview().inset(20)
        }
        failLevelImageView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        trackingImageView.snp.makeConstraints{ make in
            make.trailing.equalToSuperview().inset(UIScreen.main.bounds.width * 0.05)
            make.bottom.equalToSuperview().inset(40)
        }
        trackingTextImageView.snp.makeConstraints{ make in
            make.leading.equalToSuperview().inset(UIScreen.main.bounds.width * 0.05)
            make.bottom.equalToSuperview().inset(40)
        }
        
        
    }
    
    private func initLivesUI() {
        livesStack.axis = .horizontal
        livesStack.distribution = .fillEqually
        for _ in 1...config.connectGameSceneParameters.maxLives {
            let imageView = UIImageView()
            imageView.image = lifeFilled
            imageView.contentMode = .scaleAspectFit
            livesStack.addArrangedSubview(imageView)
            livesImageViews.append(imageView)
        }
        livesImageViews.reverse()
    }
    
    // MARK: functions being called outside?
    
    func hide(_ onHidden: (() -> Void)?) {
        self.hideAllMenus()
        self.isUserInteractionEnabled = false
        self.alpha = 0
        onHidden?()
    }
    
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.alpha = 1
    }
    
    func loadGamePlayView(livesLeft: Int, onTrackingAnimationComplete: (() -> Void)?) {
        self.show{}
        self.showTrackingAnimation(onComplete: {
            self.setLives(to: livesLeft)
            self.showLifeUI()
            self.loadTopBar{}
            onTrackingAnimationComplete?()
        })
     }
    
    func hideGamePlayView() {
        
    }
    
    func showTrackingAnimation(onComplete: (() -> Void)?) {
        UIView.animate(withDuration: 0.5, delay: 5, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.trackingView.alpha = 0
        }, completion: { _ in
            onComplete?()
        })
    }
    
    func resetTracking() {
        self.trackingView.alpha = 1
    }
    
    func loadLevelCompleteView(){
        self.trackingView.alpha = 0
        self.loadTopBar{}
        self.hideLifeUI()
        self.showLevelCompleteOptions()
    }
    
    
    func hideLevelCompleteView(){
        
    }
    
    func showlevelFailUI() {
        self.setLives(to: 0)
        
        self.levelFailUI.transform = self.levelFailUI.transform.scaledBy(x: 1/100, y: 1/100)
        self.levelFailUI.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseInOut , animations: {
           self.levelFailUI.transform = self.levelFailUI.transform.scaledBy(x: 100, y: 100)
        }, completion: { _ in
        })
    }
    
    func hidelevelFailUI() {
        self.levelFailUI.isHidden = true
    }
    
    private func hideAllMenus() {
        self.hideLevelCompleteOptions()
        self.hideTopBar{}
        self.hidelevelFailUI()
    }
    
    // Handler functions
    
    func onTapBackButton(_ target: Any?, _ handler: Selector) {
        self.backButton.addTarget(target, action: handler, for: UIControl.Event.touchUpInside)
    }
    
    func onTapRestartButton(_ target: Any?, _ handler: Selector) {
        self.restartLevelFailButton.addTarget(target, action: handler, for: UIControl.Event.touchUpInside)
        self.restartLevelShareMenuButton.addTarget(target, action: handler, for: UIControl.Event.touchUpInside)
    }
    
    func onTapShareButton(_ target: Any?, _ handler: Selector) {
        self.shareButton.addTarget(target, action: handler, for: UIControl.Event.touchUpInside)
    }
    
    func setLives(to livesLeft: Int) {
        for i in 1...config.connectGameSceneParameters.maxLives {
            if livesLeft >= i {
                livesImageViews[i-1].image = lifeFilled
            } else {
                livesImageViews[i-1].image = lifeUnfilled
            }
        }
    }
    
    // MARK: - Load and Hide Top menu
    private func loadTopBar(_ onShowing: (() -> Void)?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.topBarStack.snp.updateConstraints { make in
                make.topMargin.equalToSuperview().offset(config.connectGameUIParameters.topBarMargin)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            onShowing?()
        })
    }
    
    private func hideTopBar(_ onHidden: (() -> Void)?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.topBarStack.snp.updateConstraints { make in
                make.topMargin.equalToSuperview().offset(config.connectGameUIParameters.topBarMarginHide)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            onHidden?()
        })
    }
    
    func hideLifeUI() {
        self.livesStack.alpha = 0
    }
    
    func showLifeUI() {
        self.livesStack.alpha = 1
    }
    
    private func showLevelCompleteOptions() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.levelEndButtonStack.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(30)
            }
            self.restartLevelShareMenuStack.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(30)
            }
            self.layoutIfNeeded()
        })
    }
    
    private func hideLevelCompleteOptions() {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.levelEndButtonStack.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(-180)
            }
            self.restartLevelShareMenuStack.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(-180)
            }
            self.layoutIfNeeded()
        })
    }
    
    func animationShareMenu(onComplete: (() -> Void)?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.levelEndButtonStack.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(-180)
            }
            self.restartLevelShareMenuStack.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(-180)
            }
            self.topBarStack.snp.updateConstraints { make in
                make.topMargin.equalToSuperview().offset(config.connectGameUIParameters.topBarMarginHide)
            }
            self.layoutIfNeeded()
        }, completion: { _ in
            onComplete?()
        })
    }
    
    func flashAnimation(onComplete: (() -> Void)?) {
        let flashView = UIView(frame: UIScreen.main.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0
        self.addSubview(flashView)
        UIView.animate(withDuration: 0.1, delay: 0, options: [UIView.AnimationOptions.curveLinear], animations: {
            flashView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [UIView.AnimationOptions.curveLinear], animations: {
                flashView.alpha = 0
            }, completion: { _ in
                 flashView.removeFromSuperview()
                 onComplete?()
            })
        })
    }
}
