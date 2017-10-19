import SnapKit

class WorkoutLogCategoryViewController: AbstractViewController {
     var category: RepositoryCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeContent()
    }
    
    func initializeContent() {
        self.addView(self.createStatisticsCard())
        self.addView(ValueLabel.create(text: "Category Completion Rate"))
        self.addView(self.createCompletionRateHistoryCard())
        
        if let category = self.category {
            for section in category.sections {
                self.addView(ValueLabel.create(text: section.title))
                
                for exercise in section.exercises {
                    self.addView(ValueLabel.create(text: exercise.title))
                }
            }
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

