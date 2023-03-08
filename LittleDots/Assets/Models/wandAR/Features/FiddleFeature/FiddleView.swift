import UIKit
import SnapKit
import SceneKit

class FiddleView: UIView, FiddleViewProtocol, UITableViewDelegate, UITableViewDataSource {
    weak var featureLogic: FiddleLogicProtocol!
    let cellReuseIdentifier = "cell"
    let tableView = UITableView()
    // MARK: - Init Functions
    
    convenience init(_ featureLogic: FeatureLogicProtocol) {
        self.init(frame: UIScreen.main.bounds)
        guard let logic = featureLogic as? FiddleLogicProtocol else {
            log.error("Invalid featureLogic provided")
            return
        }
        self.featureLogic = logic
        self.alpha = 0
        self.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(PropertyCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.isUserInteractionEnabled = false
        initUI()
    }
    
    func initUI() {
        self.frame = CGRect(x: UIScreen.main.bounds.maxX, y: CGFloat(0), width: UIScreen.main.bounds.width * config.fiddleMenuUIParameters.screenPercentageCovered, height: UIScreen.main.bounds.height)
        self.tableView.frame =  CGRect(x: CGFloat(0), y: CGFloat(0), width: UIScreen.main.bounds.width * config.fiddleMenuUIParameters.screenPercentageCovered, height: UIScreen.main.bounds.height)
        self.tableView.isScrollEnabled = true
        self.tableView.rowHeight = config.fiddleMenuUIParameters.tableRowSize
        self.addSubview(tableView)
    }
  
    func show(_ onShowing: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.frame = CGRect(x: config.fiddleMenuUIParameters.startX, y: CGFloat(0), width: UIScreen.main.bounds.width * config.fiddleMenuUIParameters.screenPercentageCovered, height: UIScreen.main.bounds.height)
        }, completion: { _ in
            onShowing?()
        })
        self.alpha = 1
    }
    
    func hide(_ onHidden: (() -> Void)?) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.frame = CGRect(x: UIScreen.main.bounds.maxX, y: CGFloat(0), width: UIScreen.main.bounds.width * config.fiddleMenuUIParameters.screenPercentageCovered, height: UIScreen.main.bounds.height)
        }, completion: { _ in
            self.alpha = 0
            onHidden?()
        })
        self.isUserInteractionEnabled = false
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentProperty = property.tableData[indexPath.section].properties[indexPath.row]
        let cell:PropertyCell = (tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PropertyCell?)!
        cell.slider.maximumValue = currentProperty.maxBound
        cell.slider.minimumValue = currentProperty.minBound
        cell.slider.value = Float(currentProperty.value)
        cell.slider.tag = self.getTag(section: indexPath.section, index: indexPath.row)
        cell.slider.addTarget(self, action: #selector(onSliderUpdate(_:)), for: UIControl.Event.valueChanged)
        cell.value.text = String(format:"%.5f", cell.slider.value)
        cell.titleView.text = currentProperty.propertyName
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        let gameFont = UIFont(name: "FredokaOne-Regular", size: 20)
        header.textLabel?.font = gameFont
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    @objc
    func onSliderUpdate(_ sender : UISlider) {
        let (section, index) = self.getSectionandIndexFor(tag: sender.tag)
        property.tableData[section].properties[index].value = sender.value
    }
    
    private func getTag(section: Int, index: Int) -> Int {
        let tag = section * 100  + index
        return tag
    }
    
    private func getSectionandIndexFor(tag: Int) -> (Int, Int) {
        let index = tag % 100
        let section = tag / 100
        return (section, index)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return property.tableData[section].properties.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return property.tableData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return property.tableData[section].name
    }

}

class PropertyCell: UITableViewCell {
    let titleView = UILabel()
    let slider = UISlider()
    let value = UILabel()
    let view = UIStackView()
    let secondRow = UIStackView()
    let gameFont = UIFont(name: "FredokaOne-Regular", size: 16)
    
    func setupView() {
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * config.fiddleMenuUIParameters.screenPercentageCovered, height: config.fiddleMenuUIParameters.tableRowSize).insetBy(dx: 20, dy: 10)
        value.textAlignment = .right
        value.font = gameFont
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(onSliderUpdate(_:)), for: UIControl.Event.valueChanged)
        secondRow.addArrangedSubview(slider)
        secondRow.addArrangedSubview(value)
        secondRow.axis = .horizontal
        secondRow.spacing = 15
        secondRow.distribution = .fill
        view.addArrangedSubview(titleView)
        titleView.font = gameFont
        view.addArrangedSubview(secondRow)
        view.spacing = 2
        view.distribution = .equalSpacing
        view.axis = .vertical
        self.addSubview(view)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    @objc
    func onSliderUpdate(_ sender : UISlider) {
       self.value.text = String(format:"%.5f", sender.value)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

