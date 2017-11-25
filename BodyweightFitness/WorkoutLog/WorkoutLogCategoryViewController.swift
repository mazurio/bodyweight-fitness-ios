import SnapKit

class WorkoutLogCategoryViewController: AbstractViewController {
    var repositoryCategory: RepositoryCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeContent()
    }
    
    func initializeContent() {
        if let repositoryCategory = self.repositoryCategory {
            self.addView(self.createProgressCard(repositoryCategory: repositoryCategory))
            self.addView(ValueLabel.create(text: "Category Completion Rate"))
            self.addView(self.createCompletionRateHistoryCard())
            
            for repositorySection in repositoryCategory.sections {
                self.addView(ValueLabel.create(text: repositorySection.title))
                
                for repositoryExercise in repositorySection.exercises {
                    self.addView(
                        createExerciseCard(repositoryExercise: repositoryExercise)
                    )
                }
            }
        }
    }
    
    func createProgressCard(repositoryCategory: RepositoryCategory) -> CardView {
        let card = CardView()

        let companion = ListOfRepositoryExercisesCompanion(repositoryCategory.exercises)
        let completionRate = companion.completionRate()

        let topLeftLabel = TitleLabel()
        topLeftLabel.textAlignment = .left
        topLeftLabel.text = "\(companion.numberOfCompletedExercises()) out of \(companion.numberOfExercises())"
        card.addSubview(topLeftLabel)
        
        let topLeftValue = ValueLabel()
        topLeftValue.textAlignment = .left
        topLeftValue.text = "Completed Exercises"
        card.addSubview(topLeftValue)
        
        let topRightLabel = TitleLabel()
        topRightLabel.textAlignment = .right
        topRightLabel.text = completionRate.label
        
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
    
    func createExerciseCard(repositoryExercise: RepositoryExercise) -> CardView {
        let card = CardView()
        
        let label = TitleLabel()
        label.text = repositoryExercise.title
        card.addSubview(label)
        
        let value = ValueLabel()
        value.text = "1 Set, 3 Seconds"
        card.addSubview(value)
        
        label.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(card).offset(20)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
        }
        
        value.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.left.equalTo(card).offset(16)
            make.right.equalTo(card).offset(-16)
            make.bottom.equalTo(card).offset(-20)
        }
        
        return card
    }
}

