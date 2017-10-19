import SnapKit

class WorkoutLogCategoryViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.97, alpha:1.00)
        
        self.initializeScrollView()
        self.initializeContent()
    }
    
    func initializeScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        
        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (make) -> Void in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(view)
        }
    }
    
    func initializeContent() {
        let view = self.createBackgroundView()
        let card1 = self.createStatisticsCard()
        let card2 = self.createCompletionRateHistoryCard()
       
        let card2Title = ValueLabel()
        card2Title.text = "Category Completion Rate"
        self.contentView.addSubview(card2Title)
        
        view.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(50)
        }
        
        card1.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(contentView).offset(8)
            make.left.right.equalTo(contentView).inset(8)
        }
        
        card2Title.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card1.snp.bottom).offset(16)
            make.left.right.equalTo(contentView).inset(16)
            make.bottom.equalTo(card2.snp.top).offset(-16)
        }
        
        card2.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(contentView).inset(8)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }
    
    func createBackgroundView() -> UIView {
        let view = UIView()
        
        view.backgroundColor = UIColor.primary()
        self.contentView.addSubview(view)
        
        return view
    }
    
    func createStatisticsCard() -> CardView {
        let card = CardView()
        self.contentView.addSubview(card)
        
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

