import SnapKit

class WorkoutLogCategoryViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let contentStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)
        
        self.initializeScrollView()
        self.initializeContent()
    }
    
    func initializeScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(self.view)
        }
        
        self.contentStackView.axis = .vertical
        self.contentStackView.distribution = .fill
        self.contentStackView.alignment = .fill
        self.contentStackView.spacing = 16
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.contentStackView)
    }
    
    func initializeContent() {
//        self.createBackgroundView()

        self.contentStackView.addArrangedSubview(
            self.createStatisticsCard()
        )
        
        self.contentStackView.addArrangedSubview(
            ValueLabel.create(text: "Category Completion Rate")
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.addArrangedSubview(
            self.createCompletionRateHistoryCard()
        )
        
        self.contentStackView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(8)
            make.left.equalTo(contentView).offset(8)
            make.right.equalTo(contentView).offset(-8)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }
    
    func createBackgroundView(height: Int = 50) {
        let view = UIView()
        view.backgroundColor = UIColor.primary()
        
        self.contentView.addSubview(view)
        
        view.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(height)
        }
    }
    
    func createStatisticsCard() -> CardView {
        let card = CardView()
        
        let topLeftLabel = TitleLabel()
        topLeftLabel.textAlignment = .left
        topLeftLabel.text = "1 out of 3"
        card.addSubview(topLeftLabel)
        
        let topLeftValue = ValueLabel()
        topLeftValue.textAlignment = .left
        topLeftValue.text = "Completed Exercises"
        card.addSubview(topLeftValue)
        
        let topRightLabel = TitleLabel()
        topRightLabel.textAlignment = .right
        topRightLabel.text = "33%"
        
        card.addSubview(topRightLabel)
        
        let topRightValue = ValueLabel()
        topRightValue.textAlignment = .right
        topRightValue.text = "Completion Rate"
        card.addSubview(topRightValue)
        
        topLeftLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.leading.equalTo(card).offset(16)
            
            make.right.equalTo(topRightLabel.snp.left)
            
            make.height.equalTo(24)
        }
        
        topRightLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.trailing.equalTo(card).offset(-16)
            
            make.left.equalTo(topLeftLabel.snp.right)
            
            make.height.equalTo(24)
        }
        
        topLeftValue.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLeftLabel.snp.bottom).offset(8)
            make.leading.equalTo(card).offset(16)
            
            make.right.equalTo(topRightValue.snp.left)
            
            make.bottom.equalTo(card).offset(-20)
        }
        
        topRightValue.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topRightLabel.snp.bottom).offset(8)
            make.trailing.equalTo(card).offset(-16)
            
            make.left.equalTo(topLeftValue.snp.right)
            
            make.bottom.equalTo(card).offset(-20)
        }
        
        return card
    }
    
    func createCompletionRateHistoryCard() -> CardView {
        let card = CardView()
        self.contentView.addSubview(card)
        
        let label = TitleLabel()
        label.text = "12 October 2017"
        card.addSubview(label)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-20)
        }
        
        return card
    }
}

